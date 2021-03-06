# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

require "savon"
require "nokogiri"
require "httpclient"

module BGS
  # This class is a base-class from which most Web Services will inherit.
  # This contains the basics of how to talk with the BGS SOAP API, in
  # particular, the VA's custom SOAP headers for auditing. As a bonus, it's
  # also aware of the BGS's URL patterns, making it easy to define new
  # web services as needed using some light reflection.
  class Base
    # Base-class constructor. This sets up some instance instance variables
    # for use later -- such as the client's IP, and who we are.
    # Special notes:
    # -`forward_proxy_url`, if provided, will funnel all requests to the provided
    # url instead of directly to BGS, and add the destination hostname
    # in the HTTP headers under "Host".
    # -`log` will enable `savon` logging.

    # `jumpbox_url` is to be able to test through the jumpbox.
    # in order to use this, add the following line to your jumpbox configuration in ~/.ssh/config
      # LocalForward [local port number] beplinktest.vba.va.gov:80
    # and when initializing the client, set the jumpbox_url = 'http://127.0.0.1:[local port number]'

    def initialize(env:, forward_proxy_url: nil, jumpbox_url: nil, application:,
                   client_ip:, client_station_id:, client_username:,
                   ssl_cert_file: nil, ssl_cert_key_file: nil, ssl_ca_cert: nil,
                   log: false, logger: nil)
      @application = application
      @client_ip = client_ip
      @client_station_id = client_station_id
      @client_username = client_username
      @log = log
      @logger = logger
      @env = env
      @forward_proxy_url = forward_proxy_url
      @jumpbox_url = jumpbox_url
      @ssl_cert_file = ssl_cert_file
      @ssl_cert_key_file = ssl_cert_key_file
      @ssl_ca_cert = ssl_ca_cert
      @service_name = self.class.name.split("::").last
    end

    def self.service_name
      name = self.name.split("::").last.downcase
      name = name[0..-11] if name.end_with? "webservice"
      name + "s"
    end

    def namespace_identifier
      nil # default comes from wsdl
    end

    def endpoint
      nil # default comes from wsdl
    end

    private

    def https?
      @ssl_cert_file && @ssl_cert_key_file
    end

    def wsdl
      "#{base_url}/#{bean_name}/#{@service_name}?WSDL"
    end

    def base_url
      # Proxy url or jumpbox url should include protocol, domain, and port.
      return @forward_proxy_url if @forward_proxy_url
      return @jumpbox_url if @jumpbox_url
      "#{https? ? 'https' : 'http'}://#{domain}"
    end

    def domain
      "#{@env}.vba.va.gov"
    end

    def bean_name
      "#{@service_name}Bean"
    end

    # Return the VA SOAP audit header. Given the instance variables sitting
    # off the instance, we will go ahead and construct the SOAP Header that
    # we want to send along with requests -- this is mostly used for auditing
    # who is doing what, rather than securing the communications between BGS
    # and us.
    #
    # Audit logs are great. Let's do more of them.
    def header
      # Stock XML structure {{{
      header = Nokogiri::XML::DocumentFragment.parse <<-EOXML
  <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
    <wsse:UsernameToken>
      <wsse:Username></wsse:Username>
    </wsse:UsernameToken>
    <vaws:VaServiceHeaders xmlns:vaws="http://vbawebservices.vba.va.gov/vawss">
      <vaws:CLIENT_MACHINE></vaws:CLIENT_MACHINE>
      <vaws:STN_ID></vaws:STN_ID>
      <vaws:applicationName></vaws:applicationName>
    </vaws:VaServiceHeaders>
  </wsse:Security>
  EOXML
      # }}}

      { Username: @client_username, CLIENT_MACHINE: @client_ip,
        STN_ID: @client_station_id, applicationName: @application }.each do |k, v|
        header.xpath(".//*[local-name()='#{k}']")[0].content = v
      end
      header
    end

    # Return a `savon` client all configured like we like it. Optionally,
    # logging can be enabled by passing `log: true` to the constructor
    # of any of the services.
    def client
      # Tack on the destination header if we're sending all requests
      # to a forward proxy.
      headers = {}
      headers["Host"] = domain if @forward_proxy_url

      namespaces = {
        "xmlns:v1" => "http://types.ws.css.vba.va.gov/services/v1",
      }

      savon_client_params = {
        wsdl: wsdl,
        soap_header: header,
        log: @log,
        namespaces: namespaces,
        ssl_cert_key_file: @ssl_cert_key_file,
        headers: headers,
        ssl_cert_file: @ssl_cert_file,
        ssl_ca_cert_file: @ssl_ca_cert,
        open_timeout: 10, # in seconds
        read_timeout: 600, # in seconds
        convert_request_keys_to: :none
      }
      savon_client_params[:namespace_identifier] = namespace_identifier if namespace_identifier
      savon_client_params[:endpoint] = endpoint if endpoint
      savon_client_params[:logger] = @logger if @logger

      @client ||= Savon.client(savon_client_params)
    end

    # Proxy to call a method on our web service.
    def request(method, message = nil)
      client.call(method, message: message)
    rescue HTTPClient::ConnectTimeoutError, HTTPClient::ReceiveTimeoutError, Errno::ETIMEDOUT => _err
      # re-try once assuming this was a server-side hiccup
      sleep 1
      begin
        client.call(method, message: message)
      rescue HTTPClient::ConnectTimeoutError, HTTPClient::ReceiveTimeoutError, Errno::ETIMEDOUT => transient_error
        raise BGS::TransientError.new(transient_error.to_s, 500)
      end
    rescue Savon::SOAPFault => error
      handle_request_error(error)
    end

    def handle_request_error(error)
      err_tree = error.to_hash
      message = err_tree.dig(:fault, :detail, :share_exception, :message) || err_tree.dig(:fault, :faultstring)
      code = error.http.code

      # preserve SOAPFault if the error looks like a non-share (permissions) error.
      if message.blank? or message =~ /Fault/
        raise error
      end

      # special case
      raise_public_error(Regexp.last_match(1)) if message =~ /(Logon ID .* Not Found)/

      raise BGS::ShareError.new_from_message(message, code)
    end

    def raise_public_error(logon_id)
      raise(
        BGS::PublicError,
        "#{logon_id} in the Benefits Gateway Service (BGS). Contact your ISO if you need assistance gaining access to BGS."
      )
    end
  end
end

# vim: foldmethod=marker

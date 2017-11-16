# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

require "savon"
require "nokogiri"

module BGS
  # This error is raised when the BGS SOAP API returns a ShareException
  # fault back to us. We special-case the handling to raise this custom
  # type down in `request`, where we will kick this up if we're accessing
  # something that's above our sensitivity level.
  class ShareError < StandardError
    def initialize(message)
      @message = message
      super
    end
  end

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

    def initialize(env:, base_proxy_url: nil, application:,
                   client_ip:, client_station_id:, client_username:,
                   ssl_cert_file: nil, ssl_cert_key_file: nil, ssl_ca_cert: nil,
                   log: false, use_forward_proxy: false)
      @application = application
      @client_ip = client_ip
      @client_station_id = client_station_id
      @client_username = client_username
      @log = log
      @env = env
      @forward_proxy_url = forward_proxy_url
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

    private

    def https?
      @ssl_cert_file && @ssl_cert_key_file
    end

    def wsdl
      "#{base_url}/#{bean_name}/#{@service_name}?WSDL"
    end

    def base_url
      # Proxy url should include protocol, domain, and port.
      return @base_proxy_url if @base_proxy_url
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
      headers["Host"] = domain if @forward_proxy_url.present?

      @client ||= Savon.client(
        wsdl: wsdl, soap_header: header, log: @log,
        ssl_cert_key_file: @ssl_cert_key_file,
        headers: headers,
        ssl_cert_file: @ssl_cert_file,
        ssl_ca_cert_file: @ssl_ca_cert,
        open_timeout: 30, # in seconds
        read_timeout: 30 # in seconds
      )
    end

    # Proxy to call a method on our web service.
    def request(method, message = nil)
      client.call(method, message: message)
    rescue Savon::SOAPFault => error
      exception_detail = error.to_hash[:fault][:detail]
      raise error unless exception_detail.key? :share_exception
      raise BGS::ShareError, exception_detail[:share_exception][:message]
    end
  end
end

# vim: foldmethod=marker

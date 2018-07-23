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

  class PublicError < StandardError
    attr_accessor :public_message

    def initialize(message)
      @public_message = message
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

    def initialize(env:, forward_proxy_url: nil, application:,
                   client_ip:, client_station_id:, client_username:,
                   ssl_cert_file: nil, ssl_cert_key_file: nil, ssl_ca_cert: nil,
                   log: false)
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
      return @forward_proxy_url if @forward_proxy_url
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

      @client ||= Savon.client(
        wsdl: wsdl, soap_header: header, log: @log,
        ssl_cert_key_file: @ssl_cert_key_file,
        headers: headers,
        ssl_cert_file: @ssl_cert_file,
        ssl_ca_cert_file: @ssl_ca_cert,
        open_timeout: 600, # in seconds
        read_timeout: 600, # in seconds
        convert_request_keys_to: :none
      )
    end

    # Proxy to call a method on our web service.
    def request(method, message = nil)
      try_count = 0
      begin
        # can be removed when savon > 2.11.2 is released
        client.wsdl.request.headers = { "Host" => domain } if @forward_proxy_url
        client.call(method, message: message)
      rescue Errno::ETIMEDOUT, Errno::ECONNRESET => e
        if (try_count += 1) < 3
          # 2s, 4s
          max_sleep_seconds = Float(2 ** try_count)
          sleep rand(0..max_sleep_seconds)
          retry
        else
          raise
        end
      rescue Savon::SOAPFault => error
        handle_request_error(error)
      end
    end

    def handle_request_error(error)
      raise BGS::ShareError, error.to_hash[:fault][:detail][:share_exception][:message]
    # If any of the elements in this path are undefined, we will raise a NoMethodError.
    # Default to sending the original Savon::SOAPFault (or BGS::PublicError) in this case.
    rescue NoMethodError
      # Expect error string to look something like the following:
      # Savon::SOAPFault: (S:Client) ID: {{UUID}}: Logon ID {{CSS_ID}} Not Found
      # Only extract the final clause of that error message for the public error.
      #
      # rubocop:disable Metrics/LineLength
      raise(BGS::PublicError, "#{Regexp.last_match(1)} in the Benefits Gateway Service (BGS). Contact your ISO if you need assistance gaining access to BGS.") if error.to_s =~ /(Logon ID .* Not Found)/
      # rubocop:enable Metrics/LineLength
      raise error
    end
  end
end

# vim: foldmethod=marker

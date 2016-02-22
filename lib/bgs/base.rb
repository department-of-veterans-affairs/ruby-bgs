# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

require "savon"
require "nokogiri"

module BGS
  # This class is a base-class from which most Web Services will inheret.
  # This contains the basics of how to talk with the BGS SOAP API, in
  # particular, the VA's custom SOAP headers for auditing. As a bonus, it's
  # also aware of the BGS's URL patterns, making it easy to define new
  # web services as needed using some light reflection.
  class Base
    # Base-class constructor. This sets up some instance instance variables
    # for use later -- such as the client's IP, and who we are. This also
    # takes an additional argument - `log`, which will enable `savon` logging.
    def initialize(env:, application:,
                   client_ip:, client_station_id:, client_username:,
                   log: false)
      @application = application
      @client_ip = client_ip
      @client_station_id = client_station_id
      @client_username = client_username
      @log = log
      @env = env
      @service_name = self.class.name.split("::").last
    end

    def self.service_name
      name = self.name.split("::").last.downcase
      name = name[0..-11] if name.end_with? "webservice"
      name
    end

    private

    def wsdl
      "http://#{@env}.vba.va.gov/#{bean_name}/#{@service_name}?WSDL"
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
      @client ||= Savon.client(wsdl: wsdl, soap_header: header, log: @log)
    end

    # Proxy to call a method on our web service.
    def request(method, message)
      client.call(method, message: message)
    end
  end
end

# vim: foldmethod=marker

module BGS
  class CommonSecurityServiceImplWSV1 < BGS::Base
    def self.service_name
      "common_security"
    end

    def bean_name
      "css-webservices"
    end

    # ideally BGS would fix the WSDL for this service to conform with how their own WSDLs work.

    # override what's in the wsdl
    def namespace_identifier
      "v1"
    end

    # override what's in the wsdl
    def endpoint
      "#{base_url}/#{bean_name}/#{@service_name}"
    end

    def get_css_user_stations(username)
      response = request(:get_css_user_stations_by_application_username, namespace: :v1, username: username)
      response.body[:get_css_user_stations_by_application_response][:return]
    end

    def get_security_profile(username:, station_id:, application:)
      # should all be in the header so we must temporarily override instance vars set previously.
      previous_username = @client_username
      previous_station_id = @client_station_id
      previous_application = @application
      @client_username = username
      @client_station_id = station_id
      @application = application

      begin
        response = request(:get_security_profile_from_context)
        response.body[:get_security_profile_response][:return]
      ensure
        @client_username = previous_username
        @client_station_id  = previous_station_id
        @application = previous_application
      end
    end
  end
end

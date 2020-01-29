module BGS
  class CommonSecurityServiceImplWSV1 < BGS::Base
    def self.service_name
      "common_security"
    end

    def bean_name
      "css-webservices"
    end

    def namespace_identifier
      "v1"
    end

    def get_css_user_stations(username)
      response = request(:get_css_user_stations_by_application_username, namespace: :v1, username: username)
      response.body[:get_css_user_stations_by_application_response][:return]
    end

    def get_security_profile(username:, station_id:, application:)
      # should all be in the header
      response = request(:get_security_profile_from_context)
      response.body[:get_security_profile_response][:return]
    end
  end
end

module BGS
  class SecurityWebService < BGS::Base
    def self.service_name
      "security"
    end

    def find_ptcpnt_id(station_id, user)
      response = request(:find_ptcpnt_id, "stationNumber": station_id, "userId": user)
      response.body[:find_ptcpnt_id_response][:return]
    end
  end
end

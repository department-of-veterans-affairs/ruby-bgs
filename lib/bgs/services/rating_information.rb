module BGS

  class RatingInformationService < BGS::Base

    def bean_name
      "RatingInformationService"
    end

    def self.service_name
      "rating_information"
    end

    def read_current_rating_profile_by_ptcpnt_id(veteran_id)
      response = request(:read_current_rating_profile_by_ptcpnt_id, "veteranId": veteran_id)
      return nil unless response
      response.body[:read_current_rating_profile_by_ptcpnt_id_response]
    end
  end
end

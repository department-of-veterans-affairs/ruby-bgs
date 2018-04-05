# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # Used for finding information about specific ratings
  class RatingInformationService < BGS::Base
    def bean_name
      "RatingInformationService"
    end

    def self.service_name
      "rating_profile"
    end

    # Returns issues and disabilities for a specific rating (also known as a rating profile)
    def find(participant_id:, profile_date:)
      response = request(:read_rating_profile, "veteranId": participant_id, "profileDate": profile_date)

      # Purposely avoiding much data processing here to do that in the application layer
      response.body[:read_rating_profile_response][:rba_profile]
    end
  end
end

# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # Used for finding historical data about ratings
  class RatingManagementService < BGS::Base
    def bean_name
      "RatingManagementService"
    end

    def self.service_name
      "rating_management"
    end

    def get_rating(participant_id)
      response = request(:get_rating, "veteran_id": participant_id)
      response.body[:get_rating_response]
    end
  end
end

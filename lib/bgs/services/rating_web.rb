# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # Used for finding historical data about ratings
  class RatingWebService < BGS::Base
    def bean_name
      "RatingServiceBean"
    end

    def self.service_name
      "rating_web"
    end

    def find_by_participant_id(participant_id)
      response = request(:find_rating_data_by_ptcpnt_id, "ptcpntId": participant_id)
      response.body[:find_rating_data_by_ptcpnt_id_response]
    end
  end
end

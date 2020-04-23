# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # This service is used to find the rating decision.
  class RatingWebService < BGS::Base
    def bean_name
      "RatingWebService"
    end

    def self.service_name
      "rating_web"
    end

    # This service is used to find the Rating Decision by Veteran Participant ID.
    def find_rating_decision_by_participant_id(participant_id)
      response = request(:find_rating_decn_by_ptcpnt_vet_id, "ptcnpt_vet_id": participant_id)
      response.body[:find_rating_decn_by_ptcpnt_vet_id_response]
    end
  end
end

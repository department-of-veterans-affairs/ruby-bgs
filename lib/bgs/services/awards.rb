# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # This service is used to store information about individuals the VA is
  # interested in. This information may be kept permanently, removed or discarded
  # if appropriate.
  class AwardWebService < BGS::Base
    def bean_name
      "AwardWebServiceBean"
    end

    def find_by_participant_id(participant_id)
      response = request(:find_award_bene_by_ptcpnt_vet_id, "ptcpntVetId": participant_id)
      response.body[:findAwardBeneByPtcpntVetIdResponse]
    end
  end
end

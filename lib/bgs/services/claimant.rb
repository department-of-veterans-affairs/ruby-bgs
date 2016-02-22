# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  class ClaimantWebService < BGS::Base
    def bean_name
      "ClaimantServiceBean"
    end

    def find_poa_by_participant_id(id)
      response = request(:find_poa_by_ptcpnt_id, "ptcpntId": id)
      response.body[:find_poa_by_ptcpnt_id_response][:return]
    end

    def find_general_information_by_participant_id(id)
      response = request(:find_general_information_by_ptcpnt_id, "ptcpntId": id)
      response.body[:find_general_information_by_ptcpnt_id_response][:return]
    end
  end
end

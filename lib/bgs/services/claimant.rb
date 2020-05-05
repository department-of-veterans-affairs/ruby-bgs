# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # This service gets information about a claimant.
  class ClaimantWebService < BGS::Base
    def bean_name
      "ClaimantServiceBean"
    end

    # findFlashes (shrinqf)
    #   finds the Flashes (Person Special Status) related to a file number
    def find_flashes(file_number)
      response = request(:find_flashes, "fileNumber": file_number)
      response.body[:find_flashes_response][:return]
    end

    # findPOAByPtcntId (shrinqf)
    #   finds the Power of Attorney related to a participant ID.
    def find_poa_by_participant_id(id)
      response = request(:find_poa_by_ptcpnt_id, "ptcpntId": id)
      response.body[:find_poa_by_ptcpnt_id_response][:return]
    end

    # findPOA (shrinqf)
    #   finds the Power of Attory related to a file number
    def find_poa_by_file_number(file_number)
      response = request(:find_poa, "fileNumber": file_number)
      response.body[:find_poa_response][:return]
    end

    # findDependents (shrinq3)
    #    finds the dependents for a file number
    def find_dependents(file_number)
      response = request(:find_dependents, "fileNumber": file_number)
      response.body[:find_dependents_response][:return]
    end

    # findGeneralInformationByPtcpntIds (shrinqm)
    #   finds the General Information for given ptcpntIds, flashes, diaries,
    #   and evrs. Used when a list exist, and you want information on a single
    #   claimant
    def find_general_information_by_participant_id(id)
      response = request(:find_general_information_by_ptcpnt_id, "ptcpntId": id)
      response.body[:find_general_information_by_ptcpnt_id_response][:return]
    end

    def find_all_relationships(id)
      response = request(:find_all_relationships, "ptcpntId": id)
      response.body[:find_all_relationships_response][:return][:dependents]
    end
  end
end

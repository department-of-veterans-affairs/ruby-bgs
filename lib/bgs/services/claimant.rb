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

    # uses the findFlashes as a proxy to check that the user can
    # access the specified FileNumber, a SOAPFault is returned if
    # the user cannot be accessed.
    def get_sensitivity_access(file_number)
      begin
        request(:find_flashes, "fileNumber": file_number)
      rescue Savon::SOAPFault
        return false
      end

      return true
    end

    # findPOAByPtcntId (shrinqf)
    #   finds the Power of Attorney related to a participant ID.
    def find_poa_by_participant_id(id)
      response = request(:find_poa_by_ptcpnt_id, "ptcpntId": id)
      response.body[:find_poa_by_ptcpnt_id_response][:return]
    end

    # findGeneralInformationByPtcpntIds (shrinqm)
    #   finds the General Information for given ptcpntIds, flashes, diaries,
    #   and evrs. Used when a list exist, and you want information on a single
    #   claimant
    def find_general_information_by_participant_id(id)
      response = request(:find_general_information_by_ptcpnt_id, "ptcpntId": id)
      response.body[:find_general_information_by_ptcpnt_id_response][:return]
    end
  end
end

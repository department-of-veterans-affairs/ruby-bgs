# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # This service provides the VSO organization and POA details.
  #
  # findOrgByPtcpntId      - finds the VSO organization details by Participant ID.
  # findPOAsByPtcpntId     - finds the POA details by Participant ID.
  # findPOAsByPtcpntIds    - finds the POA details by Participant IDs.
  # findPOAsByFileNumbers  - finds the POA details by File Number.
  # findPOAsByBnftClaimIds - finds the POA details by Benefit Claim ID.
  #
  class OrgWebService < BGS::Base

    def self.service_name
      "org"
    end

    # finds the VSO organization details by Participant ID.
    def find_by_participant_id(participant_id)
      response = request(:find_org_by_ptcpnt_id, "ptcpntId": participant_id)
      response.body[:find_org_by_ptcpnt_id_response][:return]
    end

    def find_poas_by_file_number(file_number)
      response = request(:find_po_as_by_file_numbers, "fileNumber": file_number)
      response.body[:find_po_as_by_file_numbers_response][:return]
    end
  end
end

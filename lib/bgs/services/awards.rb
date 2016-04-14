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

# AwardWebService
# Share Web Service
# Service Description
# This service is used to find the Award information.
# Methods
# findStationOfJurisdiction - find the current Station of Jurisdiction by Participant Veteran ID and Participant
# Beneficiary ID
# findAwardBene - find the Award Beneficiaries by Participant Veteran ID, Participant Beneficiary ID, Participant
# Recipient ID and Award Type Code
# findVeteranAwardCmpsitBySSN – find the Award Composite by SSN
# findVeteranAwardCmpsitByFileNumber - find the Award Composite by File Number
# findVeteranAwardCmpsitByPtcpntId – find the Award Composite by Participant ID
# findAwardBeneByPtcpntVetId – find the Award Beneficiaries by Participant Veteran ID
# findAwardBeneByPtcpntBeneId – find the Award Beneficiaries by Participant Beneficiary ID
# findAwardBeneByPtcpntRecipId - find the Award Beneficiaries by Participant Recipient ID
# findAwardBeneByFileNumber - find the Award Beneficiaries by File Number OR SSN and Participant Veteran ID

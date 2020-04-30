# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  #This service is used to update the rating profiles for a Veteran.
  class RatingManagementService < BGS::Base
    def bean_name
      "RatingManagementService"
    end

    def self.service_name
      "rating_management"
    end

    # This service is used to get the RBA rating data for a Veteran.  The service returns the most current rating
    # profile and all associated decisions for this rating, by Participant Veteran ID.

    # The isBackfill input parameter is used when the rating is being pulled without an associated claim to be worked,
    # usually for correction or filling of old/missing data.

    def get_rating(participant_id, is_backfill=false)
      response = request(:get_rating, "veteran_id": participant_id, "is_backfill": is_backfill)
      response.body[:get_rating_response]
    end
  end
end

response = request(:get_rating, "getRating": { veteran_id: participant_id, is_backfill: is_backfill })

"RatingDateRange": {
  "ptcpntId": participant_id,
  "startDate": start_date,
  "endDate": end_date,
  # This flag allows the service to return ratings that are not locked
  # if the most current rating is locked
  "allowLockedRatings": "Y",
  # This field isn't used and should be set to the start_date
  # according to the BGS team.
  "claimDate": start_date
}

response = request(
  :manage_claimant_letter_v2,
  "letter": {
    "letters": {
      "clmId": claim_id,
      "developmentActions": {
        "createDt": DateTime.now,
        "fedAgencyInd": "Y",
        "nm": "HLR - Informal Conference",
        "pgmTc": program_type_cd,
        "prgrphId": "1",
        "ptcpntId": claimant_participant_id,
        "rulesBasedInd": "4",
        "stdDevactnCd": "GNRLCLAIM",
        "stdDevactnId": DEVELOPMENT_ACTION_IDS[program_type_cd],
        "stdactnDescp": "HLR - Informal Conference",
        "suspnsDuratn": "30",
        "suspnsDys": "30",
        "suspnsUnit": "DAYS"
      },
      "dvlpmtTc": "CLMNTRQST",
      "fileSttTc": "INDVLPMT",
      "outdcmtTc": "DV",
      "printDt": DateTime.now,
      "ptcpntDcmntTn": "Receiver",
      "ptcpntId": claimant_participant_id,
      "templatTc": "VSCNP"
    }
  },
  "generateClaimantLetter": true
)

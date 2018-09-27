module BGS
  class DocumentService < BGS::Base
    def bean_name
      "DocumentService"
    end

    def self.service_name
      "documents"
    end

    DEVELOPMENT_ACTION_IDS = {
      "CPL" => "42924",
      "CPD" => "42925"
    }.freeze

    def find_claimant_letters(document_id)
      response = request(:find_claimant_letters, "documentId": document_id)
      response.body[:find_claimant_letters_response]
    end

    def manage_claimant_letter_v2(claim_id:, program_type_cd:, claimant_participant_id:)
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
      response.body[:manage_claimant_letter_v2_response][:envelope][:letters][:docid]
    end

    # Generates the tracked items based on developmentActions in the letters
    # in the claimant letter
    def generate_tracked_items(claim_id)
      response = request(:generate_tracked_items, "claimId": claim_id)
      response.body[:generate_tracked_items_response][:benefit_claim][:dvlpmt_items][:dvlpmt_item_id]
    end
  end
end

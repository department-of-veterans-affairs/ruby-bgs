module BGS
  class BenefitClaimWebService < BGS::Base
    def bean_name
      "BenefitClaimServiceBean"
    end

    def self.service_name
      "claims"
    end

    def find_by_vbms_file_number(file_number)
      response = request(:find_benefit_claim, "fileNumber": file_number)

      response.body[:find_benefit_claim_response][:return][:participant_record][:selection] ||
        response.body[:find_benefit_claim_response][:return][:participant_record] || []
    end

    def find_claim_detail_by_id(id)
      response = request(:find_benefit_claim_detail, "benefitClaimId": id)

      response.body[:find_benefit_claim_detail_response][:return] || []
    end

    # We have no idea what reason 1 is, these are only being used in UAT for testing purposes
    def clear_end_product(file_number:, end_product_code:, modifier:, reason: "1")
      response = request(:clear_benefit_claim, "clearBenefitClaimInput": {
                           "fileNumber": file_number,
                           "payeeCode": "00",
                           "benefitClaimType": "1",
                           "endProductCode": end_product_code,
                           "incremental": modifier,
                           "pclrReasonCode": reason
                         })

      response.body || []
    end

    def cancel_end_product(file_number:, end_product_code:, modifier:, reason: "1")
      response = request(:cancel_benefit_claim, "cancelBenefitClaimInput": {
                           "fileNumber": file_number,
                           "payeeCode": "00",
                           "benefitClaimType": "1",
                           "endProductCode": end_product_code,
                           "incremental": modifier,
                           "pcanReasonCode": reason
                         })

      response.body || []
    end
  end
end

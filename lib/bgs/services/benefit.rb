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

      response.body[:find_benefit_claim_response][:return][:participant_record][:selection] || []
    end
  end
end
module BGS
  class BenefitClaimWebService < BGS::Base
    def bean_name
      "BenefitClaimWebServiceBean"
    end

    def self.service_name
      "benefit_claims"
    end

    def find_claim_by_file_number(file_number)
      response = request(:find_bnft_claim_by_file_number, "fileNumber": file_number)
      response.body[:find_bnft_claim_by_file_number_response][:bnft_claim_dto]
    end
  end
end

module BGS
  class DocumentService < BGS::Base
    def bean_name
      "DocumentService"
    end

    def self.service_name
      "documents"
    end

    def find_claimant_letters(document_id)
      response = request(:find_claimant_letters, "documentId": document_id)
      response.body[:find_claimant_letters_response][:return]
    end

    def manage_claimant_letter_V2(letter)
      # manage_claimant_letter__V2 converts to manageClaimantLetter_V2
      response = request(
        :manage_claimant_letter__V2,
        "letter": {
          "letters": letter
        },
        "generateClaimantLetter": true
      )

      response.body[:manage_claimant_letter__V2][:return][:envelope][:letters][:doc_id]
    end

    # Generates the tracked items based on developmentActions in the letters
    # in the claimant letter
    # Returns the BenefitClaim, which will include the development actions and letters
    def generate_tracked_items(claim_id)
      response = request(:generate_tracked_items, "claimId": claim_id)
      response.body[:generate_tracked_items_response][:return]
    end
  end
end

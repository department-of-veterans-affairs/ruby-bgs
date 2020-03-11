# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # This service gets information about a veteran's contention.
  class ContentionWebService < BGS::Base
    def bean_name
      "ContentionService"
    end

    def self.service_name
      "contention"
    end

    # Find contention by claim_id.
    def find_contention_by_claim_id(claim_id)
      response = request(:find_contentions, "claimId": claim_id)
      response.body[:find_contentions_response][:benefit_claim]
    end
  end
end

# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # This service is used to find Standard Data from Share.
  class StandardDataWebService < BGS::Base
    def self.service_name
      "data"
    end

    # This method is used to find all the Power of Attorney Data.
    def find_power_of_attorneys
      response = request(:find_po_as)
      response.body[:find_po_as_response][:power_of_attorney_dto]
    end

    # Used to find out which payee codes are valid for which end product type
    def find_payee_codes_for_end_product(veteran_is_deceased, end_product_code)
      response = request(:find_payee_cds_by_bnft_claim_type_cd,
        "shareComndTypeCd": "CEST",
        "pgmTypeCd": veteran_is_deceased ? "CPD" : "CPL",
        "svcTypeCd": "CP",
        "bnftClaimTypeCd": end_product_code
      )
      response.body[:find_payee_cds_by_bnft_claim_type_cd_response][:payee_type_dto]
    end
  end
end

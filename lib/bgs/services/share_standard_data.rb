module BGS
  class ShareStandardDataService < BGS::Base
    def bean_name
      "ShareStandardDataServiceBean"
    end

    def self.service_name
      "share_standard_data"
    end

    def find_diagnostic_codes
      response = request(:find_diagnostic_codes)
      response.body[:find_diagnostic_codes_response]
    end

    def find_pay_grades
      response = request(:find_pay_grades)
      response.body[:find_pay_grades_response]
    end
  end
end
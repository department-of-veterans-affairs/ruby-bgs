module BGS
  class ShareStandardDataService < BGS::Base
    def bean_name
      "ShareStandardDataServiceBean"
    end

    def self.service_name
      "share_standard_data"
    end

    def find_diagnostic_codes(file_number)
      response = request(:find_diagnostic_codes, "fileNumber": file_number)
      response.body[:find_diagnostic_codes_response]
    end
  end
end
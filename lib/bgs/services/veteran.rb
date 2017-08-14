# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # This service is used to retrieve detailed information about a veteran.
  class VetRecordService < BGS::Base
    def bean_name
      "VetRecordServiceBean"
    end

    def self.service_name
      "veteran"
    end

    def find_by_file_number(file_number)
      response = request(:find_veteran_by_file_number, "fileNumber": file_number)
      response = response.body[:find_veteran_by_file_number_response][:return]

      birls_record = response[:vet_birls_record] || {}
      corp_record = response[:vet_corp_record] || {}
      backwards_compatibility = {
        sex: birls_record[:sex_code]
      }

      birls_record
        .merge(corp_record)
        .merge(backwards_compatibility)
    end
  end
end

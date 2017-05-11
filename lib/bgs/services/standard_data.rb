# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # This service is used to find Standard Data from Share.
  class StandardDataWebService < BGS::Base
    def self.service_name
      "standard_data"
    end

    # This method is used to find all the Power of Attorney Data.
    def find_power_of_attorneys
      response = request(:find_po_as)
      response.body[:find_po_as_response][:power_of_attorney_dto]
    end
  end
end

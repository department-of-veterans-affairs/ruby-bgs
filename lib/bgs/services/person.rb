# As a work of the United States Government, this project is in the
# public domain within the United States.
# 
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS

  # This service is used to store information about individuals the VA is
  # interested in. This information may be kept permanently, removed or discarded
  # if appropriate.
  class PersonWebService < BGS::Base
  
    # Find a Person, as defined by the Person Web Service, by their SSN.
    def find_by_ssn(ssn)
      response = request(:find_person_by_ssn, {"ssn": ssn})
      return response.body[:find_person_by_ssn_response][:person_dto]
    end
  end
end

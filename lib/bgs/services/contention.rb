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

    # # Find a Person, as defined by the Person Web Service, by their File
    # # Number.
    # def find_by_file_number(file_number)
    #   response = request(:find_person_by_file_number, "fileNumber": file_number)
    #   response.body[:find_person_by_file_number_response][:person_dto]
    # end

    # def find_person_by_ptcpnt_id(participant_id)
    #   response = request(:find_person_by_ptcpnt_id, "ptcpntId": participant_id)
    #   response.body[:find_person_by_ptcpnt_id_response][:person_dto]
    # end

    # def find_relationships_by_ptcpnt_id_relationship_type(participant_id, type)
    #   response = request(:find_relationships_by_ptcpnt_id_relationship_type, "ptcpntId": participant_id, "type": type)
    #   response.body[:find_relationships_by_ptcpnt_id_relationship_type_response][:person_dto]
    # end

    # def find_employee_by_participant_id(participant_id)
    #   response = request(:find_employee_by_ptcpnt_id, "ptcpntId": participant_id)
    #   response.body[:find_employee_by_ptcpnt_id_response][:employee_dto]
    # end
  end
end

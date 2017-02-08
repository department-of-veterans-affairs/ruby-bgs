# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # This service is used to store notes associated with a claim
  class DevelopmentNoteService < BGS::Base
    def self.bean_name
      "DevelopmentNotesService"
    end

    def self.service_name
      "DevelopmentNotesService"
    end

    # Create a new note
    def create_note(claim_id:, note:)
      response = request(:create_note, "claimId": claim_id, "note": note)
      response.body[:find_person_by_ssn_response][:person_dto]
    end
  end
end

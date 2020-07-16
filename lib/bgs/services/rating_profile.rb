# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # Used for finding information about specific ratings
  class RatingInformationService < BGS::Base
    def bean_name
      "RatingInformationService"
    end

    def self.service_name
      "rating_profile"
    end

    # Returns issues and disabilities for a specific rating (also known as a rating profile)
    def find(participant_id:, profile_date:)
      response = request(:read_rating_profile, "veteranId": participant_id, "profileDate": profile_date)

      # Purposely avoiding much data processing here to do that in the application layer
      response.body[:read_rating_profile_response][:rba_profile]
    end

    # Returns rating profiles within the date range with rating issues for decisions that were at issue
    # response includes backfilled ratings
    def find_in_date_range(participant_id:, start_date:, end_date:)
      response = request(
        :get_all_decns_at_issue_for_date_range,
        "veteranID": participant_id,
        "startDate": start_date,
        "endDate": end_date
      )
      response.body[:get_all_decns_at_issue_for_date_range_response][:decns_at_issue_for_date_range]
    end
    
    # Returns current rating profile by participant_id
    def find_current_rating_profile_by_ptcpnt_id(participant_id, include_issues=true)
      response = request(:read_current_rating_profile_by_ptcpnt_id, "veteranId": participant_id, "includeIssues": include_issues)
      response.body[:read_current_rating_profile_by_ptcpnt_id_response][:rba_profile]
    end
  end
end


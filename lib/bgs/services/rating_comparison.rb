# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # Used for finding historical data about ratings
  class RatingComparisonEJBService < BGS::Base
    def bean_name
      "RatingComparisonEJB"
    end

    def self.service_name
      "rating"
    end

    # Returns a wide variety of information about the current profile and ratings in
    # the specified date range.
    def find_by_participant_id_and_date_range(participant_id, start_date, end_date)
      response = request(
        :compare_by_date_range,
        "RatingDateRange": {
          "ptcpntId": participant_id,
          "startDate": start_date,
          "endDate": end_date,
          # This flag allows the service to return ratings that are not locked
          # if the most current rating is locked
          "allowLockedRatings": "Y",
          # This field isn't used and should be set to the start_date
          # according to the BGS team.
          "claimDate": start_date
        }
      )

      # Purposely avoiding much data processing here to do that in the application layer
      response.body[:compare_by_date_range_response][:return]
    end
  end
end

# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  #This service is used to update the rating profiles for a Veteran.
  class RatingManagementService < BGS::Base
    def bean_name
      "RatingManagementService"
    end

    def self.service_name
      "rating_management"
    end

    # This service is used to get the RBA rating data for a Veteran.  The service returns the most current rating
    # profile and all associated decisions for this rating, by Participant Veteran ID.

    # The isBackfill input parameter is used when the rating is being pulled without an associated claim to be worked,
    # usually for correction or filling of old/missing data.

    def get_rating(participant_id, is_backfill=false)
      response = request(:get_rating, veteranId: participant_id, isBackfill: is_backfill)
      response.body[:get_rating_response]
    end
  end
end

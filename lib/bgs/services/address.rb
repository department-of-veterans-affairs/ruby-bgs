# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

module BGS
  # This service is used to find the address information.
  class AddressWebService < BGS::Base
    def self.service_name
      "address"
    end

    # Finds a PTCPNT_ADDRS row for the given ptcpnt_id and address type
    def find_by_participant_id(participant_id, participant_address_type_name="Mailing")
      response = request(
        :find_ptcpnt_addrs, "ptcpntId": participant_id, "ptcpntAddrsTypeNm": participant_address_type_name
      )
      response.body[:find_ptcpnt_addrs_response][:return]
    end

    # Finds all the PTCPNT_ADDRS rows that do not have an end_date, for the provided
    # ptcpnt_id
    def find_all_by_participant_id(participant_id)
      response = request(
        :find_all_ptcpnt_addrs_by_ptcpnt_id, "ptcpntId": participant_id
      )
      response.body[:find_all_ptcpnt_addrs_by_ptcpnt_id_response][:return]
    end
  end
end

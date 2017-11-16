# As a work of the United States Government, this project is in the
# public domain within the United States.
#
# Additionally, we waive copyright and related rights in the work
# worldwide through the CC0 1.0 Universal public domain dedication.

# This file will go ahead and require all the web services that have been
# included to date, so that when a user requests `bgs`, they have all the
# required classes.
#
# All Services should be in the BGS module, not BGS::Services::*, since
# the entire point of this gem is to talk with BGS Web Services. It's
# organized like this to keep conceptual things at a glance, and then dig
# in to the implementation(s) (really: declarations)

require "bgs/services/person"
require "bgs/services/org"
require "bgs/services/claimant"
require "bgs/services/awards"
require "bgs/services/benefit"
require "bgs/services/veteran"
require "bgs/services/standard_data"
require "bgs/services/address"

# Now, we're going to declare a class to hide the actual creation of service
# objects, since having to construct them all really sucks.

module BGS
  class Services
    def initialize(env:, application:,
                   client_ip:, client_station_id:, client_username:,
                   forward_proxy_url: nil,
                   ssl_cert_file: nil, ssl_cert_key_file: nil, ssl_ca_cert: nil,
                   log: false)

      @config = { env: env, application: application, client_ip: client_ip,
                  client_station_id: client_station_id,
                  client_username: client_username,
                  ssl_cert_file: ssl_cert_file,
                  ssl_cert_key_file: ssl_cert_key_file,
                  ssl_ca_cert: ssl_ca_cert,
                  forward_proxy_url: forward_proxy_url,
                  log: log }
    end

    def self.all
      ObjectSpace.each_object(Class).select { |klass| klass < BGS::Base }
    end

    BGS::Services.all.each do |service|
      define_method(service.service_name) do
        service.new @config
      end
    end

    # High level utility function to determine if a record can be accessed
    # in the current configuration. The logic on reading flashes this way
    # was grafted from how VBMS checks to see if the sensitivity level is
    # appropriate.
    #
    # If you need flashes later, it's likely better to find_flashes directly,
    # and catch a BGS::ShareError if it's not allowed.
    #
    # This also requires the claimants service to have been implicitly loaded
    # above; which can break if the require at the top is removed, or if the
    # name changes.
    def can_access?(ssn)
      claimants.find_flashes(ssn).nil?
      return true
    rescue BGS::ShareError
      return false
    end
  end
end

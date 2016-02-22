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

# Now, we're going to declare a class to hide the actual creation of service
# objects, since having to construct them all really sucks.

module BGS
  class Services
    def initialize(env:, application:,
                   client_ip:, client_station_id:, client_username:,
                   log: false)

      @config = { env: env, application: application, client_ip: client_ip,
                  client_station_id: client_station_id,
                  client_username: client_username, log: log }
    end

    def self.all
      ObjectSpace.each_object(Class).select { |klass| klass < BGS::Base }
    end

    BGS::Services.all.each do |service|
      define_method(service.service_name) do
        service.new @config
      end
    end
  end
end

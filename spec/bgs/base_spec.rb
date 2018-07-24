require "bgs"

# rubocop:disable Metrics/BlockLength
describe BGS::Base do
  let(:file_number) { "123456789" }
  let(:bgs_base) do
    BGS::TestBase.new(
      env: "beplinktest",
      application: "TEST_APP",
      client_ip: "127.0.0.1",
      client_station_id: 283,
      client_username: "VACOUSERT",
      forward_proxy_url: nil,
      log: true
    )
  end

  # Build Savon::SOAPFaults how the library builds them.
  # https://github.com/savonrb/savon/blob/e76ecc00b84b998b012ecc33b55ca1edd443ec55/spec/savon/soap_fault_spec.rb
  let(:response_body) { nil }
  let(:http_response) { HTTPI::Response.new(500, {}, response_body) }
  let(:nori) { Nori.new(strip_namespaces: true, convert_tags_to: ->(tag) { tag.snakecase.to_sym }) }
  let(:soap_fault) { Savon::SOAPFault.new(http_response, nori) }

  context "When Savon::Client.call() raises a generic Savon::SoapFault" do
    let(:response_body) do
      %(<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
   <soap:Body>
      <soap:Fault>
         <faultcode>soap:Server</faultcode>
         <faultstring>Fault occurred while processing.</faultstring>
      </soap:Fault>
   </soap:Body>
</soap:Envelope>)
    end

    it "BGS::Base.request raises a Savon::SOAPFault" do
      allow_any_instance_of(Savon::Client).to receive(:call).and_raise(soap_fault)
      expect { bgs_base.test_request(:method) }.to raise_error(Savon::SOAPFault)
    end
  end

  context "When BGS::ClaimantWebService.find_flashes() raises a logon not found error" do
    let(:fault_string) { "Logon ID VACOHSOLO Not Found" }
    let(:response_body) do
      %(<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
   <soap:Body>
      <soap:Fault>
         <faultcode>soap:Server</faultcode>
         <faultstring>#{fault_string}</faultstring>
      </soap:Fault>
   </soap:Body>
</soap:Envelope>)
    end
    let(:error_string) do
      # rubocop:disable Metrics/LineLength
      "#{fault_string} in the Benefits Gateway Service (BGS). Contact your ISO if you need assistance gaining access to BGS."
      # rubocop:enable Metrics/LineLength
    end

    it "BGS::Base raises a BGS::PublicError that has a public_message" do
      allow_any_instance_of(Savon::Client).to receive(:call).and_raise(soap_fault)
      expect { bgs_base.test_request(:method) }.to raise_error do |error|
        expect(error).to be_a(BGS::PublicError)
        expect(error).to respond_to(:public_message)
        expect(error.public_message).to eq(error_string)
      end
    end
  end

  context "When BGS::PersonWebService.find_by_ssn() has a timeout" do
    let (:errno_timeout) { Errno::ETIMEDOUT.new }

    it "BGS::Base retries intermittent network failures" do
      @times_called = 0
      allow_any_instance_of(Savon::Client).to receive(:call).and_return do
        @times_called += 1
        raise errno_timeout if @times_called <= 1
        'ok'
      end

      expect(bgs_base.test_request(:method, nil)).to eq('ok')
    end

    it "BGS::Base gives up on persistent network errors" do
      allow_any_instance_of(Savon::Client).to receive(:call).and_raise(errno_timeout)
      
      expect { bgs_base.test_request(:method) }.to raise_error do |error|
        expect(error).to be_a(Errno::ETIMEDOUT)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength

# Helper class to allow us to test BGS::Base's private request() method.
module BGS
  class TestBase < BGS::Base
    def test_request(method, message = nil)
      request(method, message)
    end
  end
end

require "bgs"
require "pry"

def default_soap_body(message)
  %(<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
       <soap:Fault>
          <faultcode>soap:Server</faultcode>
          <faultstring>Fault occurred while processing.</faultstring>
          <Detail>
             <ShareException>
               <Message>#{message}</Message>
             </ShareException>
          </Detail>
       </soap:Fault>
    </soap:Body>
 </soap:Envelope>)
end

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
      jumpbox_url: nil,
      log: true
    )
  end

  # Build Savon::SOAPFaults how the library builds them.
  # https://github.com/savonrb/savon/blob/e76ecc00b84b998b012ecc33b55ca1edd443ec55/spec/savon/soap_fault_spec.rb
  let(:response_body) { nil }
  let(:http_response) { HTTPI::Response.new(500, {}, response_body) }
  let(:nori) { Nori.new(strip_namespaces: true, convert_tags_to: ->(tag) { tag.snakecase.to_sym }) }
  let(:soap_fault) { Savon::SOAPFault.new(http_response, nori) }
  let(:timeout_error) { Errno::ETIMEDOUT.new }

  context "When Savon::Client receives a connection timeout error" do
    it "re-tries one time" do
      allow_any_instance_of(Savon::Client).to receive(:call).and_raise(timeout_error)
      expect(bgs_base).to receive(:client).twice.and_call_original
      expect { bgs_base.test_request(:method) }.to raise_error(BGS::TransientError)
    end
  end

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

    it "raises a Savon::SOAPFault" do
      allow_any_instance_of(Savon::Client).to receive(:call).and_raise(soap_fault)
      expect(bgs_base).to receive(:client).once.and_call_original
      expect { bgs_base.test_request(:method) }.to raise_error do |error|
        expect(error.class).to eq Savon::SOAPFault
        expect(error.message).to eq "(soap:Server) Fault occurred while processing."
      end
    end
  end

  context "when Savon::SoapFault with a transient ShareException message" do
    let(:message) { "Connection reset by peer" }
    let(:response_body) { default_soap_body(message) }

    it "raises a transient BGS::ShareError" do
      allow_any_instance_of(Savon::Client).to receive(:call).and_raise(soap_fault)

      expect { bgs_base.test_request(:method) }.to raise_error do |error|
        expect(error.class).to eq BGS::ShareError
        expect(error.message).to eq message
        expect(error.code).to eq 500
        expect(error).to be_ignorable
      end
    end
  end

  context "when Savon::SoapFault with a non-transient ShareException message" do
    let(:message) { "not transient" }
    let(:response_body) { default_soap_body(message) }

    it "raises a non-transient BGS::ShareError" do
      allow_any_instance_of(Savon::Client).to receive(:call).and_raise(soap_fault)

      expect { bgs_base.test_request(:method) }.to raise_error do |error|
        expect(error.class).to eq BGS::ShareError
        expect(error.message).to eq message
        expect(error.code).to eq 500
        expect(error).to_not be_ignorable
      end
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

  context "when Savon::SoapFault with a known error" do
    let(:message) { "Power of Attorney of Folder is none. Access to this record is denied." }
    let(:response_body) { default_soap_body(message) }

    it "raises a BGS::PowerOfAttorneyFolderDenied error" do
      allow_any_instance_of(Savon::Client).to receive(:call).and_raise(soap_fault)

      expect { bgs_base.test_request(:method) }.to raise_error do |error|
        expect(error.class).to eq BGS::PowerOfAttorneyFolderDenied
        expect(error.message).to eq message
        expect(error.code).to eq 500
        expect(error).to_not be_ignorable
      end
    end
  end

  context "when css user stations error" do
    let(:response_body) do
      %(<S:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
  <env:Header/>
  <S:Body>
     <ns0:Fault xmlns:ns0="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://www.w3.org/2003/05/soap-envelope">
        <faultcode>ns0:Server</faultcode>
        <faultstring>Unable to get user authroization due to a framework fault</faultstring>
        <detail>
           <ns0:cssRepoGenericFault xmlns:ns0="http://types.ws.css.vba.va.gov/services/v1">
              <message>Error getting CSS User from Corporate</message>
           </ns0:cssRepoGenericFault>
        </detail>
     </ns0:Fault>
  </S:Body>
</S:Envelope>
      )
    end

    it "raises a non-transient BGS::ShareError" do
      allow_any_instance_of(Savon::Client).to receive(:call).and_raise(soap_fault)

      expect { bgs_base.test_request(:method) }.to raise_error do |error|
        expect(error.class).to eq BGS::ShareError
        expect(error.message).to eq "Error getting CSS User from Corporate"
        expect(error.code).to eq 500
        expect(error).to_not be_ignorable
      end
    end
  end

  context "explicit endpoint" do
    before do
      allow_any_instance_of(Savon::Client).to receive(:call) do |client, soap_method|
        @endpoint_used = client.wsdl.endpoint
        true
      end
    end

    it "uses the explicit subclass endpoint in requests" do
      expect(bgs_base.endpoint).to eq "override-the-wsdl"
      expect(bgs_base.send(:client).wsdl.endpoint).to eq "override-the-wsdl"
      expect(bgs_base.test_request(:method)).to eq true
      expect(@endpoint_used).to eq "override-the-wsdl"
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

    def endpoint
      "override-the-wsdl"
    end
  end
end

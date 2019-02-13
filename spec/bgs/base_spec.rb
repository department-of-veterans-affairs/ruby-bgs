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
      external_uid: 'test',
      external_key: '12345',
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

  context "building the savon client" do
    it "should intiate the client from the options with the external options" do
      base = BGS::TestBase.new(
        env: "beplinktest",
        application: "TEST_APP",
        client_ip: "127.0.0.1",
        client_station_id: 283,
        client_username: "VACOUSERT",
        external_uid: 'test',
        external_key: '12345',
        ssl_cert_key_file: "mycertkeyfile.crt",
        ssl_cert_file: "mycertfile.crt",
        ssl_ca_cert: "mycacertfile.crt"
      )
      expect(base.instance_eval{client_options}[:ssl_cert_key_file]).to eq("mycertkeyfile.crt")
      expect(base.instance_eval{client_options}[:ssl_cert_file]).to eq("mycertfile.crt")
      expect(base.instance_eval{client_options}[:ssl_ca_cert_file]).to eq("mycacertfile.crt")
    end

    it 'should add the external headers if present?' do
        base = BGS::TestBase.new(
          env: "beplinktest",
          application: "TEST_APP",
          client_ip: "127.0.0.1",
          client_station_id: 283,
          client_username: "VACOUSERT",
          external_uid: 'test',
          external_key: '12345'
        )
        header_to_match = '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
           <wsse:UsernameToken>
             <wsse:Username>VACOUSERT</wsse:Username>
           </wsse:UsernameToken>
           <vaws:VaServiceHeaders xmlns:vaws="http://vbawebservices.vba.va.gov/vawss">
             <vaws:CLIENT_MACHINE>127.0.0.1</vaws:CLIENT_MACHINE>
             <vaws:STN_ID>283</vaws:STN_ID>
             <vaws:ExternalUid>test</vaws:ExternalUid><vaws:ExternalKey>12345</vaws:ExternalKey>
             <vaws:applicationName>TEST_APP</vaws:applicationName>
           </vaws:VaServiceHeaders>
         </wsse:Security>'.gsub(/\s+/, "")
        expect(base.instance_eval{header}.to_s.gsub(/\s+/, "")).to eq(header_to_match)
    end

    it 'should not add the external headers if not assigned' do
        base = BGS::TestBase.new(
          env: "beplinktest",
          application: "TEST_APP",
          client_ip: "127.0.0.1",
          client_station_id: 283,
          client_username: "VACOUSERT",
        )
        header_to_match = '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
           <wsse:UsernameToken>
             <wsse:Username>VACOUSERT</wsse:Username>
           </wsse:UsernameToken>
           <vaws:VaServiceHeaders xmlns:vaws="http://vbawebservices.vba.va.gov/vawss">
             <vaws:CLIENT_MACHINE>127.0.0.1</vaws:CLIENT_MACHINE>
             <vaws:STN_ID>283</vaws:STN_ID>
             <vaws:applicationName>TEST_APP</vaws:applicationName>
           </vaws:VaServiceHeaders>
         </wsse:Security>'.gsub(/\s+/, "")
        expect(base.instance_eval{header}.to_s.gsub(/\s+/, "")).to eq(header_to_match)
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

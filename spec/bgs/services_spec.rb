require "bgs"

describe BGS::Services do
  let(:file_number) { "123456789" }
  let(:bgs_client) do
    BGS::Services.new(
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

  context "When BGS::ClaimantWebService.find_flashes() raises a generic Savon::SoapFault" do
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

    it "BGS::Services.can_access? raises a Savon::SOAPFault" do
      allow_any_instance_of(BGS::ClaimantWebService).to receive(:find_flashes).and_raise(soap_fault)
      expect { bgs_client.can_access?(file_number) }.to raise_error(Savon::SOAPFault)
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
    let(:error_string) { "#{fault_string} in the Benefits Gateway Service (BGS). Contact your ISO if you need assistance gaining access to BGS." }

    it "BGS::Services.can_access? raises a BGS::PublicError that has a public_message" do
      allow_any_instance_of(BGS::ClaimantWebService).to receive(:find_flashes).and_raise(soap_fault)

      expect { bgs_client.can_access?(file_number) }.to raise_error { |error|
        expect(error).to be_a(BGS::PublicError)
        expect(error).to respond_to(:public_message)
        expect(error.public_message).to eq(error_string)
      }
    end
  end
end

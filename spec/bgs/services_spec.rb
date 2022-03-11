require "bgs"

describe BGS::Services do
  let(:bgs) do
    BGS::Services.new(
      env: "bepprod",
      application: "CASEFLOW",
      client_ip: "0.0.0.0",
      client_station_id: "317",
      client_username: "FAKEUSER",
      ssl_cert_file: nil,
      ssl_cert_key_file: nil,
      ssl_ca_cert: nil,
      forward_proxy_url: nil,
      jumpbox_url: nil,
      log: true,
      logger: nil
    )
  end

  describe "#client_station_id" do
    subject { bgs.client_station_id }

    it "returns 317" do
      expect(subject).to eq("317")
    end
  end

  describe "#client_username" do
    subject { bgs.client_username }

    it "returns FAKEUSER" do
      expect(subject).to eq("FAKEUSER")
    end
  end
end

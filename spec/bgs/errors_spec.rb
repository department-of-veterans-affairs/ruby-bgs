require "bgs"

describe BGS::ShareError do
  context "body has invalid UTF8" do
    it "replaces invalid UTF8 with blank string" do
      body = "invalid\255"
      error = BGS::ShareError.new(body, 500)

      expect(error.body).to eq "invalid"
      expect(error.message).to eq "invalid"
      expect(error.code).to eq 500
    end
  end
end

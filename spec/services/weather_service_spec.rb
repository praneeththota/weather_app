require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  let(:address) { "Hyderabad, India" }
  let(:service) { described_class.new(address) }

  before do
    Rails.cache.clear
  end

  context "when address is blank" do
    it "returns :missing_address" do
      result = described_class.new("").fetch_forecast
      expect(result).to eq([nil, :missing_address])
    end
  end

  context "when address is invalid" do
    it "returns :not_found" do
      stub_request(:get, /nominatim.openstreetmap.org/)
        .to_return(status: 200, body: "[]", headers: { 'Content-Type' => 'application/json' })

      result = service.fetch_forecast
      expect(result).to eq([nil, :not_found])
    end
  end

  context "when address is valid" do
    before do
      stub_request(:get, /nominatim.openstreetmap.org/)
        .to_return(
          status: 200,
          body: [
            {
              "lat" => "17.3850",
              "lon" => "78.4867",
              "display_name" => "Hyderabad, Telangana, India, 500001"
            }
          ].to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      stub_request(:get, /api.open-meteo.com/)
        .to_return(
          status: 200,
          body: {
            "current_weather" => { "temperature" => 30 },
            "daily" => {
              "temperature_2m_max" => [34],
              "temperature_2m_min" => [25]
            }
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end
  end
end

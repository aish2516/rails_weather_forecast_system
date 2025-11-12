require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  before do
    allow(Rails.application.credentials).to receive(:dig).with(:openweather_api_key).and_return("test_api_key")
  end

  describe "get_forecast" do
    it "fetches weather data for a given zip code", :vcr do
      zip_code = "10001"
      
      stub_request(:get, /api.openweathermap.org/)
        .to_return(status: 200, body: { name: "New York", main: { temp: 22, temp_max: 25, temp_min: 18 }, weather: [{ description: "Clear sky" }] }.to_json, headers: { 'Content-Type' => 'application/json' })

      response = WeatherService.get_forecast(zip_code)
      
      expect(response).to be_a(Hash)
      expect(response).to have_key(:temperature)
    end

    it "handles API key missing error", :vcr do
      allow(Rails.application.credentials).to receive(:dig).with(:openweather_api_key).and_return(nil)
      expect { WeatherService.get_forecast("10001") }.to raise_error(StandardError, "API key is missing")
    end

    it "handles network errors gracefully", :vcr do
      allow(Net::HTTP).to receive(:get_response).and_raise(StandardError.new("Network issue"))
      
      response = WeatherService.get_forecast("10001")
      expect(response).to eq({ error: "Failed to fetch weather data" })
    end
  end
end


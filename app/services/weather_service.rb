require 'httparty'

class WeatherService
  include HTTParty
  BASE_URL = 'https://api.openweathermap.org/data/2.5/weather'.freeze

  def self.get_forecast(zip_code)
    api_key = Rails.application.credentials.dig(:openweather_api_key)
    raise StandardError, 'API key is missing' if api_key.nil? || api_key.strip.empty?

    response = HTTParty.get("#{BASE_URL}?zip=#{zip_code},us&appid=#{api_key}&units=metric")

    if response.success?
      data = response.parsed_response
      {
        name: data['name'],
        temperature: data['main']['temp'],
        high: data['main']['temp_max'],
        low: data['main']['temp_min'],
        condition: data['weather'][0]['description']
      }
    else
      { error: 'Failed to fetch weather data' }
    end
  end
end

class WeatherController < ApplicationController
  before_action :validate_address, only: [:fetch_weather]

  def fetch_weather
    zip_code = Geocoder.search(params[:address])&.first&.postal_code
    return handle_invalid_address if zip_code.nil?

    weather, cached = fetch_weather_data(zip_code)

    @weather = if weather.nil? || weather[:error]
                 { error: 'Failed to fetch weather data' }
               else
                 WeatherDecorator.new(weather)
               end

    @cached = cached
    render :fetch_weather
  end

  private

  def validate_address
    return unless params[:address].blank?

    flash[:alert] = 'Address cannot be blank.'
    redirect_to root_path
  end

  def handle_invalid_address
    flash[:alert] = 'Invalid address. Please try again.'
    redirect_to root_path
  end

  def fetch_weather_data(zip_code)
    api_key = Rails.application.credentials.dig(:openweather_api_key)
    return [{ error: 'Missing API key' }, false] if api_key.blank?

    cache_key = "weather_forecast_#{zip_code}"

    # ✅ Check cache first (30 min)
    if Rails.cache.exist?(cache_key)
      cached_weather = Rails.cache.read(cache_key)
      return [cached_weather, true]
    end

    location = Geocoder.search(zip_code)&.first
    country_code = location&.country_code || 'us'

    # --- Current Weather ---
    current_url = "https://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},#{country_code}&units=metric&appid=#{api_key}"

    begin
      response = HTTParty.get(current_url)
      puts "DEBUG Current URL: #{current_url}"
      puts "DEBUG STATUS: #{response.code}"

      json_data = JSON.parse(response.body)

      if response.code == 200
        weather_data = {
          name: json_data['name'],
          temperature: json_data.dig('main', 'temp'),
          max_temp: json_data.dig('main', 'temp_max'),
          min_temp: json_data.dig('main', 'temp_min'),
          condition: json_data.dig('weather', 0, 'description')
        }

        # --- Extended 5-Day Forecast ---
        forecast_url = "https://api.openweathermap.org/data/2.5/forecast?zip=#{zip_code},#{country_code}&units=metric&appid=#{api_key}"
        forecast_response = HTTParty.get(forecast_url)

        if forecast_response.code == 200
          forecast_data = JSON.parse(forecast_response.body)
          # ✅ pick one forecast per day at ~12:00 PM (5 distinct days)
          forecast_list = forecast_data['list'].select { |f| f['dt_txt'].include?('12:00:00') }.first(5).map do |item|
            {
              date: item['dt_txt'],
              temp: item['main']['temp'],
              condition: item['weather'][0]['description']
            }
          end
          weather_data[:forecast] = forecast_list
        else
          puts "Forecast fetch failed: #{forecast_response.body}"
        end

        # ✅ Cache data for 30 minutes
        Rails.cache.write(cache_key, weather_data, expires_in: 30.minutes)

        [weather_data, false] # from Live API
      else
        [{ error: json_data['message'] || 'Failed to fetch weather data' }, false]
      end
    rescue StandardError => e
      [{ error: "Error fetching weather data: #{e.message}" }, false]
    end
  end
end

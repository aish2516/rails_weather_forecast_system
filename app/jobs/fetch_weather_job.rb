class FetchWeatherJob
  include Sidekiq::Worker

  def perform(zip_code)
    weather = WeatherService.get_forecast(zip_code)
    Rails.cache.write("weather_#{zip_code}", weather, expires_in: 30.minutes) unless weather[:error]
  end
end
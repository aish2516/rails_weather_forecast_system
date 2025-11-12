class WeatherFactory
  def self.create(api_response)
    {
      name: api_response['name'],
      temperature: api_response['main']['temp'],
      high: api_response['main']['temp_max'],
      low: api_response['main']['temp_min'],
      condition: api_response['weather'].first['description']
    }
  end
end
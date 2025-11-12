# Rails Weather Forecast System

## Overview
The Rails Weather Forecast System is a Ruby on Rails application that retrieves weather data for a given address. It integrates with an external weather API and caches responses to improve performance. The application follows best practices by using design patterns such as **Decorator, Service Object, and Factory**, and implements background jobs for efficiency.

## Features
- Fetches weather data based on a given address.
- Displays current temperature, high/low temperature, and weather conditions.
- Caches weather data in **Redis** for 30 minutes per zip code.
- Utilizes **background jobs** to asynchronously process weather updates.
- Implements **RSpec** for unit and integration tests.
- Securely manages API keys via **Rails credentials**.

## Tech Stack
- **Ruby on Rails 5.2.8**
- **Ruby 2.7.6**
- **Redis** (for caching)
- **Sidekiq** (for background jobs)
- **RSpec** (for testing)
- **Hotwire** (for real-time updates)

### 🧾 Example Output  

**Current Weather for Cupertino, CA**  
**Temperature:** 23°C  
**Feels Like:** 22°C  
**Humidity:** 40%  
**High:** 25°C  
**Low:** 17°C  
🌐 *Data retrieved live from OpenWeather API*  

---

### 📅 5-Day Forecast  

| Date | Temp | High | Low | Condition |
|------|------|------|------|-----------|
| **Nov 12** | 23°C | 25°C | 17°C | Clear sky |
| **Nov 13** | 24°C | 27°C | 16°C | Few clouds |
| **Nov 14** | 21°C | 24°C | 15°C | Scattered clouds |
| **Nov 15** | 22°C | 25°C | 14°C | Clear sky |
| **Nov 16** | 23°C | 26°C | 15°C | Clear sky |


## Design Patterns Used
### 1. Decorator Pattern
The **Decorator Pattern** is used to encapsulate and extend the functionality of weather data responses.

**File:** `app/decorators/weather_decorator.rb`
```ruby
class WeatherDecorator
  def initialize(data)
    @data = data
  end

  def name
    @data[:name]
  end

  def temperature
    @data[:temperature]
  end

  def max_temp
    @data[:max_temp]
  end

  def min_temp
    @data[:min_temp]
  end

  def condition
    @data[:condition]
  end
end
```

### 2. Service Object Pattern
The **Service Object Pattern** is used to separate business logic for fetching weather data.

**File:** `app/services/weather_service.rb`
```ruby
class WeatherService
  def initialize(zip_code)
    @zip_code = zip_code
  end

  def fetch
    response = ExternalWeatherApi.fetch_weather(@zip_code)
    response.success? ? response.body : { error: 'Failed to fetch weather data' }
  end
end
```

### 3. Factory Pattern
The **Factory Pattern** is used to create objects dynamically based on API responses.

**File:** `app/factories/weather_factory.rb`
```ruby
class WeatherFactory
  def self.build(data)
    return nil if data.nil?
    WeatherDecorator.new(data)
  end
end
```

## Background Jobs
The app uses **Sidekiq** for background jobs to fetch and cache weather data asynchronously.

**File:** `app/jobs/fetch_weather_job.rb`
```ruby
class FetchWeatherJob < ApplicationJob
  queue_as :default

  def perform(zip_code)
    weather_data = WeatherService.new(zip_code).fetch
    Rails.cache.write(zip_code, weather_data, expires_in: 30.minutes)
  end
end
```

## Testing
Testing is implemented using **RSpec**.

- **Unit Tests**: Test models, services, and decorators.
- **Integration Tests**: Ensure API requests and caching work as expected.
- **Background Job Tests**: Verify job execution and caching logic.

**Example Test Case:** `spec/services/weather_service_spec.rb`
```ruby
require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  let(:zip_code) { '10001' }
  subject { described_class.new(zip_code) }

  it 'fetches weather data successfully' do
    allow(ExternalWeatherApi).to receive(:fetch_weather).and_return(OpenStruct.new(success?: true, body: { temperature: 20 }))
    expect(subject.fetch).to eq({ temperature: 20 })
  end

  it 'handles errors' do
    allow(ExternalWeatherApi).to receive(:fetch_weather).and_return(OpenStruct.new(success?: false))
    expect(subject.fetch).to eq({ error: 'Failed to fetch weather data' })
  end
end
```

## Caching with Redis
- Weather data is cached in **Redis** for 30 minutes.
- The cache is refreshed when a new request is made after expiration.

**Fetching Cached Data:**
```ruby
cached_data = Rails.cache.read(zip_code)
```

## API Key Management
- The **OpenWeather API Key** is stored securely in **Rails credentials**.
- It is accessed using:
  ```ruby
  Rails.application.credentials.dig(:openweather_api_key)
  ```
- To set the API key, run:
  ```sh
  EDITOR=vim rails credentials:edit
  ```
  and add:
  ```yaml
  openweather_api_key: YOUR_API_KEY_HERE
  ```

## How to Run the App
1. **Install dependencies:**
   ```sh
   bundle install
   yarn install
   ```
2. **Start Redis** (for caching and Sidekiq jobs):
   ```sh
   redis-server
   ```
3. **Start Sidekiq** (for background jobs):
   ```sh
   bundle exec sidekiq
   ```
4. **Start the Rails server:**
   ```sh
   rails server
   ```
5. **Access the app:**
   Open `http://localhost:3000` in a browser.

## Conclusion
This application follows best practices by incorporating **design patterns, background jobs, caching, and secure API management**. The **Decorator, Service Object, and Factory** patterns improve maintainability and readability. Background jobs ensure that API calls do not block user interactions, and Redis caching optimizes performance. The app is well-tested using **RSpec** to ensure reliability.


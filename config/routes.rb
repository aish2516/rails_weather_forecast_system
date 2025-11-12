Rails.application.routes.draw do

  root 'weather#index'
  get 'weather/fetch_weather', to: 'weather#fetch_weather'
  post 'fetch_weather', to: 'weather#fetch_weather'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

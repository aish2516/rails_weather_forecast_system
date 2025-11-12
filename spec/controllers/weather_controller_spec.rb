require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe "POST #fetch_weather" do
    it "redirects to root if address is blank" do
      post :fetch_weather, params: { address: "" }
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("Address cannot be blank.")
    end
  end
end
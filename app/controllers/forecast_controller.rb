class ForecastController < ApplicationController
  include HTTParty

  BASE_URL = "https://api.open-meteo.com/v1/forecast"
  GEOCODE_URL = "https://nominatim.openstreetmap.org/search"

  def new
  end

  def show
    address = params[:address]
    if address.blank?
      flash[:alert] = "Please enter an address."
      redirect_to root_path and return
    end

    geo_data = HTTParty.get(GEOCODE_URL, query: { q: address, format: "json", limit: 1 }).parsed_response
    if geo_data.empty?
      flash[:alert] = "Address not found."
      redirect_to root_path and return
    end

    lat = geo_data[0]["lat"]
    lon = geo_data[0]["lon"]
    zip = geo_data[0]["display_name"].split(',').last.strip rescue "unknown"

    cache_key = "forecast_#{zip}"

    if Rails.cache.exist?(cache_key)
      @forecast = Rails.cache.read(cache_key)
      @from_cache = true
    else
      response = HTTParty.get(BASE_URL, query: {
        latitude: lat,
        longitude: lon,
        current_weather: true,
        daily: "temperature_2m_max,temperature_2m_min",
        timezone: "auto"
      }).parsed_response

      @forecast = {
        temperature: response["current_weather"]["temperature"],
        high: response["daily"]["temperature_2m_max"].first,
        low: response["daily"]["temperature_2m_min"].first
      }
      #byebug
      Rails.cache.write(cache_key, @forecast, expires_in: 30.minutes)
      @from_cache = false
    end
  end
end

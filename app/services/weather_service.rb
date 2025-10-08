# app/services/weather_service.rb
require 'httparty'

class WeatherService
  include HTTParty

  GEOCODE_URL = "https://nominatim.openstreetmap.org/search"
  BASE_URL = "https://api.open-meteo.com/v1/forecast"

  def initialize(address)
    @address = address
  end

  def fetch_forecast
    return [nil, :missing_address] if @address.blank?

    geo_data = HTTParty.get(GEOCODE_URL, query: { q: @address, format: "json", limit: 1 }).parsed_response
    return [nil, :not_found] if geo_data.empty?

    lat = geo_data[0]["lat"]
    lon = geo_data[0]["lon"]
    zip = geo_data[0]["display_name"].split(',').last.strip rescue "unknown"

    cache_key = "forecast_#{zip}"

    if Rails.cache.exist?(cache_key)
      forecast = Rails.cache.read(cache_key)
      return [forecast, true]
    end

    response = HTTParty.get(BASE_URL, query: {
      latitude: lat,
      longitude: lon,
      current_weather: true,
      daily: "temperature_2m_max,temperature_2m_min",
      timezone: "auto"
    }).parsed_response

    forecast = {
      temperature: response["current_weather"]["temperature"],
      high: response["daily"]["temperature_2m_max"].first,
      low: response["daily"]["temperature_2m_min"].first
    }

    Rails.cache.write(cache_key, forecast, expires_in: 30.minutes)
    [forecast, false]
  end
end

class ForecastController < ApplicationController
  include HTTParty

  BASE_URL = "https://api.open-meteo.com/v1/forecast"
  GEOCODE_URL = "https://nominatim.openstreetmap.org/search"

  def new
  end

  def show
    service = WeatherService.new(params[:address])
    @forecast, result = service.fetch_forecast

    case result
    when :missing_address
      flash[:alert] = "Please enter an address."
      redirect_to root_path
    when :not_found
      flash[:alert] = "Address not found."
      redirect_to root_path
    else
      @from_cache = result
    end
  end
end

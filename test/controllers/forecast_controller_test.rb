require "test_helper"

class ForecastControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get forecast_new_url
    assert_response :success
  end

  test "should get show" do
    get forecast_show_url
    assert_response :success
  end
end

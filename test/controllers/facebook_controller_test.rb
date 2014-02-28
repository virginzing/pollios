require 'test_helper'

class FacebookControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

end

require 'test_helper'

class WebPanel::PollsControllerTest < ActionController::TestCase

  test "should get poll_latest" do
    get :poll_latest
  end

  test "should get poll_latest_in_public" do
    get :poll_latest_in_public
  end

  test "should get poll_popular" do
    get :poll_popular
  end

  test "should get create_new_poll" do
    get :create_new_poll
  end

  test "should get create_new_public_poll" do
    get :create_new_public_poll
  end

end

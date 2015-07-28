require 'test_helper'

class PublicSurveys::PollsControllerTest < ActionController::TestCase
  include SessionsHelper

  setup do
    @member = members(:one)
    @poll = polls(:one)
    @group = groups(:one)
    @company = companies(:one)
    @group_company = group_companies(:one)
    @group_member = group_members(:one)
    cookies[:auth_token] = @member.auth_token
  end

  def test_should_get_polls
    get :index
    assert_response :success
  end

  def test_should_get_new_poll
    get :new
    assert_response :success
  end

  def test_should_show_poll
    get(:show, { 'id' => @poll.id })
    assert_response :success
  end

  def test_should_update_poll
    get(:update, { 'id' => @poll.id })
    assert_response :success
  end

end

require "test_helper"

class PublicSurveys::FeedbacksControllerTest < ActionController::TestCase
  include SessionsHelper

  setup do
    @member = members(:one)
    @poll = polls(:one)
    @feedback = poll_series(:one)
    @group = groups(:one)
    @company = companies(:one)
    @group_company = group_companies(:one)
    @group_member = group_members(:one)
    cookies[:auth_token] = @member.auth_token
  end

  def test_should_get_feedbacks
    get :index
    assert_response :success
  end

  def test_should_get_new_feedback
    get :new
    assert_response :success
  end

  def test_should_show_feedback
    get(:show, { 'id' => @feedback.id })
    assert_response :success
  end

  def test_should_update_feedback
    get(:update, { 'id' => @feedback.id })
    assert_response :success
  end

end

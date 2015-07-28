require "test_helper"

class PublicSurveys::CampaignsControllerTest < ActionController::TestCase
  include SessionsHelper

  setup do
    @member = members(:one)
    @poll = polls(:one)
    @campaign = campaigns(:one)
    @group = groups(:one)
    @company = companies(:one)
    @group_company = group_companies(:one)
    @group_member = group_members(:one)
    cookies[:auth_token] = @member.auth_token
  end

  def test_should_get_campaigns
    get :index
    assert_response :success
  end

  def test_should_get_new_campaign
    get :new
    assert_response :success
  end

  def test_should_edit_campaign
    get(:edit, { 'id' => @campaign.id })
    assert_response :success
  end

end

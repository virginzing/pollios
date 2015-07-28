require "test_helper"

class PublicSurveys::GroupsControllerTest < ActionController::TestCase
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

  def test_should_get_groups
    get :index
    assert_response :success
  end

  def test_should_get_new_group
    get :new
    assert_response :success
  end

  def test_should_get_show_group
    get(:show, { 'id' => @group.id } )
    assert_response :success
  end

  def test_should_get_edit_group
    get(:edit, { 'id' => @group.id })
    assert_response :success
  end

  def test_should_get_new_poll_in_groups
    get :new_poll
    assert_response :success
  end

end

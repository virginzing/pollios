require 'test_helper'

class WebPanel::PollsControllerTest < ActionController::TestCase

  setup do
    @request.headers['Accept'] = Mime::JSON
    @request.headers['Content-Type'] = Mime::JSON.to_s

    @member = members(:one)
    @poll = polls(:one)
    @group = groups(:one)
    @company = companies(:one)
    @group_company = group_companies(:one)
    @group_member = group_members(:one)
  end

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

  test "should get load_poll" do
    get :load_poll
  end

  test "should get create_poll" do
    get :create_poll
  end

  test "should get poke_poll" do
    post :poke_poll, format: :json
  end

  test "should get poke_dont_vote" do
    post :poke_dont_vote, { member_id: @member.id, id: @poll.id }, format: :json
  end

  test "should get poke_dont_view" do
    post :poke_dont_view, { member_id: @member.id, id: @poll.id }, format: :json
  end

  test "should get poke_view_no_vote" do
    post :poke_view_no_vote, { member_id: @member.id, id: @poll.id }, format: :json
  end

end

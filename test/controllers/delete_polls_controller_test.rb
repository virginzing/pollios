require 'test_helper'

class DeletePollsControllerTest < ActionController::TestCase
  setup do
    @delete_poll = delete_polls(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:delete_polls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create delete_poll" do
    assert_difference('DeletePoll.count') do
      post :create, delete_poll: { creator: @delete_poll.creator, delete_at: @delete_poll.delete_at, poll: @delete_poll.poll, voter: @delete_poll.voter }
    end

    assert_redirected_to delete_poll_path(assigns(:delete_poll))
  end

  test "should show delete_poll" do
    get :show, id: @delete_poll
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @delete_poll
    assert_response :success
  end

  test "should update delete_poll" do
    patch :update, id: @delete_poll, delete_poll: { creator: @delete_poll.creator, delete_at: @delete_poll.delete_at, poll: @delete_poll.poll, voter: @delete_poll.voter }
    assert_redirected_to delete_poll_path(assigns(:delete_poll))
  end

  test "should destroy delete_poll" do
    assert_difference('DeletePoll.count', -1) do
      delete :destroy, id: @delete_poll
    end

    assert_redirected_to delete_polls_path
  end
end

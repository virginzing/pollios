require 'test_helper'

class RecurringsControllerTest < ActionController::TestCase
  setup do
    @recurring = recurrings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:recurrings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create recurring" do
    assert_difference('Recurring.count') do
      post :create, recurring: { end_recur: @recurring.end_recur, member_id: @recurring.member_id, period: @recurring.period, status: @recurring.status }
    end

    assert_redirected_to recurring_path(assigns(:recurring))
  end

  test "should show recurring" do
    get :show, id: @recurring
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @recurring
    assert_response :success
  end

  test "should update recurring" do
    patch :update, id: @recurring, recurring: { end_recur: @recurring.end_recur, member_id: @recurring.member_id, period: @recurring.period, status: @recurring.status }
    assert_redirected_to recurring_path(assigns(:recurring))
  end

  test "should destroy recurring" do
    assert_difference('Recurring.count', -1) do
      delete :destroy, id: @recurring
    end

    assert_redirected_to recurrings_path
  end
end

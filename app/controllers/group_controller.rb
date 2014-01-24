class GroupController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :set_current_member

  def my_group
    
  end

  def create_group
    @group = @current_member.create_group(create_group_params)
  end

  def add_friend_to_group
    @group = @current_member.add_friends_to_group(group_params[:friend_id], group_params)
  end

  def accept_group
    @group = @current_member.accept_group(group_params[:group_id])
  end

  def deny_group
    @group = @current_member.deny_or_leave_group(group_params[:group_id])
  end

  def leave_group
    @group = @current_member.deny_or_leave_group(group_params[:group_id])
  end

  def delete_group
    @group  = @current_member.delete_group(group_params[:group_id])
  end

  private

  def create_group_params
    params.permit(:name, :photo_group, :group_id, :friend_id)
  end

  def group_params
    params.permit(:name, :photo_group, :group_id, :friend_id => [])
  end
end

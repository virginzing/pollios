class GroupController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :set_current_member, only: [:my_group]

  def my_group
    @group_active = @current_member.get_group_active
    @group_inactive = @current_member.get_group_inactive
  end

  def build_group
    @group =  Group.build_group(group_params)
  end

  def add_friend_to_group
    @group = Group.add_friend_to_group(group_params[:group_id], group_params[:member_id], group_params[:friend_id] )
  end

  def accept_group
    @group = Group.accept_group(group_params)
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

  def group_params
    params.permit(:id, :name, :photo_group, :group_id, :member_id, :friend_id)
  end
end

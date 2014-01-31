class GroupController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :set_current_member

  def my_group
    
  end

  def build_group
    @group =  Group.build_group(group_params)
  end

  def add_friend_to_group
    @group = Group.add_friend_to_group(group_params)
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
    params.permit(:name, :photo_group, :group_id, :member_id, :friend_id)
  end
end

module WebPanel
  class AddUserToGroupController < ApplicationController

    layout 'admin'
    before_filter :authenticate_admin!, :redirect_unless_admin

    def index
      @groups = Group.where("lower(name) LIKE ?", "%#{params[:q].downcase}%") if params[:q].present?
    end

    def members_with_group
      @users = UserToGroupService.new({group_id: params[:group_id], fullname: params[:fullname]}).users
      render layout: false
    end

    def remote_user_to_group
      user_to_group = UserToGroupService.new({group_id: params[:group_id], member_id: params[:member_id]})

      if user_to_group.add!
        render json: { error_message: nil }, status: :ok
      else
        render json: { error_message: user_to_group.error_message }, status: :unprocessable_entity
      end
    end

  end
end

class SuggestGroupsController < ApplicationController
  layout 'admin'

  skip_before_action :verify_authenticity_token, only: [:login_as, :create_notification]

  before_filter :authenticate_admin!


  def manage_groups
    @group = Group.where(public: true)
    @current_suggest_group = SuggestGroup.all.pluck(:group_id)
  end


  def create
    group_select = suggest_group_params[:group_select]

    if group_select
      SuggestGroup.delete_all

      group_select.each do |group_id|
        SuggestGroup.create!(group_id: group_id)
      end

      SuggestGroup.flush_cached_all  

      flash[:success] = "Successfully created"
    else
      flash[:notice] = "Select at least 1 group"
    end

    redirect_to admin_suggest_groups_path
  end



  private

  def suggest_group_params
    params.permit(:group_select => [])
  end

end

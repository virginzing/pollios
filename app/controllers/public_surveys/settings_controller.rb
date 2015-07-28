class PublicSurveys::SettingsController < ApplicationController
  include SymbolHash

  before_action :only_public_survey, except: [:editable]

  def index

  end

  def editable
    find_member = Member.find(params[:member_id])
    old_name ||= find_member.get_name

    find_member.fullname = setting_params[:fullname]
    find_member.description = setting_params[:description]
    find_member.show_recommend = setting_params[:show_recommend].to_b

    if find_member.fullname_changed?
      NotifyLog.edit_message_that_change_name(find_member, setting_params[:fullname], old_name)
      Activity.create_activity_my_self(find_member, ACTION[:change_name])
    end

    if find_member.save
      flash[:success] = "Successfully updated account."
      redirect_to(:back)
    end
  end

  private

  def setting_params
    params.permit(:fullname, :description, :show_recommend)
  end

end

class TemplatesController < ApplicationController

  before_action :authenticate_with_token!, only: [:new_or_update, :poll_template]

  def new_or_update
    member_template = @current_member.get_template

    if member_template.present?
      member_template.update(poll_template: params[:poll_template])
    else
      new_template = Template.create!(member_id: @current_member.id, poll_template: params[:poll_template])
    end
    @templates = member_template || new_template
  end

  def poll_template
    @templates = @current_member.get_template
  end

  private

  def template_params
    params.permit(:member_id)
  end

end

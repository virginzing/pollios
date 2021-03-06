class SurveyorController < ApplicationController

  def load_surveyor
    find_member = Member.find_by(id: params[:id])
    respond_to do |wants|
      if find_member.present?
        wants.json { render json: Hash["group_id" => find_member.surveyor_in_group.map(&:id)] }
      else
        raise ExceptionHandler::NotFound, ExceptionHandler::Message::Member::NOT_FOUND
      end
    end
  end
end

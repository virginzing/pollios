class SurveyorController < ApplicationController


  def load_surveyor
    find_member = Member.find_by(id: params[:id])
    respond_to do |wants|
      if find_member.present?
        wants.json { render json: Hash["group_id" => find_member.surveyor_in_group.map(&:id)] }
      else
        wants.json { render json: { error_message: "Member not found or something went wrong" }, status: 403 }
      end
    end
  end
end

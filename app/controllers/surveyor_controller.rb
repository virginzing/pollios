class SurveyorController < ApplicationController


  def load_surveyor
    find_member = Member.find(params[:id])

    respond_to do |wants|
      wants.json { render json: Hash["group_id" => find_member.surveyor_in_group.map(&:id)] }
    end

  end
end

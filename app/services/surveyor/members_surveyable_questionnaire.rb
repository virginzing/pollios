class Surveyor::MembersSurveyableQuestionnaire
  def initialize(questionnaire, params = {})
    @questionnaire = questionnaire
    @params = params
  end

  def surveyed
    Member.find_by(id: @params[:surveyed_id])
  end

  def get_members_in_group
    @get_member_in_group ||= members_in_group
  end

  def get_members_voted
    member_ids = check_member_that_in_group

    Member.where(id: member_ids)
  end

  def check_member_that_in_group
    members_voted.pluck(:id).uniq & get_members_in_group.map(&:id)
  end

  def survey
    @questionnaire.vote_questionnaire(@params, surveyed, @questionnaire)
  end

  private

  def members_in_group
    Member.includes(:groups).where("groups.id IN (?) AND group_members.active = 't'", questionnaire_in_group).uniq.references(:groups)
  end

  def questionnaire_in_group
    @questionnaire.in_group_ids.split(",")
  end

  def members_voted
    @questionnaire.who_voted
  end

  
end
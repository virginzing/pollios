class QuestionnaireDetailCompany

  def initialize(questionnaire, options={})
    @questionnaire = questionnaire
    @options = options
  end

  def questionnaire_in_groups
    @questionnaire.groups
  end

  def questionnaire_id
    @questionnaire.id
  end

  def get_member_in_group
    @member_active ||= group_member_active_ids
  end

  def get_member_voted_questionnaire
    @member_voted_questionnaire ||= list_history_vote_questionnaire
  end

  def get_member_not_voted_questionnaire
    @member_not_voted_questionnaire ||= Member.where("id IN (?)", group_member_active_ids - get_member_voted_questionnaire.map(&:id))
  end

  def get_member_viewed_questionnaire
    @member_viewed_questionnaire ||= list_history_view_questionnaire.select {|e| e if e.viewed_at.present? }
  end

  def get_member_not_viewed_questionnaire
    @member_not_viewed_questionnaire ||= Member.where("id IN (?)", group_member_active_ids - get_member_viewed_questionnaire.map(&:id))
  end

  def get_member_viewed_not_vote_questionnaire
    get_member_viewed_questionnaire.select {|e| e unless get_member_voted_questionnaire.map(&:id).include?(e.id) }
  end

  private

  def group_member_active
    list_member_ids_active = []
    questionnaire_in_groups.each do |group|
      list_member_ids_active << group.get_member_active.map(&:id)
    end
    list_member_ids_active
  end

  def group_member_active_ids
    group_member_active.flatten.uniq
  end
  
  def list_history_vote_questionnaire
    Member.joins("left outer join history_votes on members.id = history_votes.member_id")
          .where("history_votes.poll_series_id = ? AND members.id IN (?)", questionnaire_id, group_member_active_ids).uniq
  end

  def list_history_view_questionnaire
    Member.joins("left outer join history_view_questionnaires on members.id = history_view_questionnaires.member_id")
          .select("members.*, history_view_questionnaires.created_at as viewed_at")
          .where("history_view_questionnaires.poll_series_id = ? AND members.id IN (?)", questionnaire_id, group_member_active_ids)
  end

end
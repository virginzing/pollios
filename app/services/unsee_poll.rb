class UnseePoll
  def initialize(params)
    @params = params
  end

  def member_id
    @params[:member_id]
  end

  def poll_id
    @params[:poll_id]
  end

  def get_list_questionnaire_id
    query_unsee_poll.select{|e| e if e.unseeable_type == "PollSeries" }.map(&:unseeable_id)
  end

  def get_list_poll_id
    query_unsee_poll.select{|e| e if e.unseeable_type == "Poll" }.map(&:unseeable_id)
  end

  def delete_unsee_poll
    if query_unsee_poll_with_id.present?
      query_unsee_poll_with_id.destroy 
      true
    end
  end

  private

  def query_unsee_poll
    @query ||= UnSeePoll.where(member_id: member_id)
  end

  def query_unsee_poll_with_id
    UnSeePoll.find_by(member_id: member_id, unseeable_id: poll_id)
  end
end
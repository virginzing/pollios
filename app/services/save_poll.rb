class SavePoll

  def initialize(params)
    @params = params
  end

  def member_id
    @params[:member_id]
  end

  def get_list_questionnaire_id
    query_save_poll.select{|e| e if e.savable_type == "PollSeries" }.map(&:savable_id)
  end

  def get_list_poll_id
    query_save_poll.select{|e| e if e.savable_type == "Poll" }.map(&:savable_id)
  end

  private

  def query_save_poll
    @query ||= SavePollLater.where(member_id: member_id)
  end

    
end
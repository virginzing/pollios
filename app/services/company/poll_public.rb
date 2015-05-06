class Company::PollPublic
  def initialize(company)
    @company = company
  end

  def get_list_public_poll
    @get_list_public_poll ||= public_poll
  end

  private

  def public_poll
    @query = Poll.without_deleted.includes(:choices, :history_votes, :member, :poll_series)
                  .where("polls.member_id = #{@company.member_id} AND polls.public = 't' AND polls.series = 'f'")
                  .order("polls.created_at DESC").uniq
    @query
  end
  
  
end
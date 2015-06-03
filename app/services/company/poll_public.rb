class Company::PollPublic
  def initialize(company)
    @company = company
  end

  def get_list_public_poll
    @get_list_public_poll ||= public_poll
  end

  private

  def public_poll
    @query = Poll.without_deleted.joins(:poll_company).includes(:choices, :member, :poll_series)
                  .where("poll_companies.company_id = #{@company.id} AND polls.public = 't' AND polls.series = 'f'")
                  .order("polls.created_at DESC").uniq
    @query
  end
  
  
end
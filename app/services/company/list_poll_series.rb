class Company::ListPollSeries
  def initialize(company)
    @company = company
  end

  def poll_series_ids
    @poll_series_ids ||= poll_series.pluck(:id)
  end

  def access_poll_series?(poll_series)
    poll_series_ids.include?(poll_series.id)
  end

  private

  def poll_series
    @company.poll_series
  end
  
  
end
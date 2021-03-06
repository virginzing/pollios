class Company::ListPollSeries
  def initialize(company)
    @company = company
  end

  def list_poll_series
    @list_poll_series ||= poll_series
  end

  def only_internal_survey
    list_poll_series.select{|poll_series| poll_series unless poll_series.public }
  end

  def only_public_survey
    list_poll_series.select{|poll_series| poll_series.public }
  end

  def poll_series_ids
    @poll_series_ids ||= list_poll_series.pluck(:id)
  end

  def access_poll_series?(poll_series)
    poll_series_ids.include?(poll_series.id)
  end

  private

  def poll_series
    @company.poll_series.without_deleted
  end


end

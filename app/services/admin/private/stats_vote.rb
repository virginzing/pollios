module Admin::Private::StatsVote

  private

  def dashboard_vote
    return dashboard_vote_today if @filter_by == FilterByStats::TODAY
  end

  def dashboard_vote_today
    puts dashboard_graph_vote
    {
      count: poll_today.count,
      graph: dashboard_graph_vote
    }
  end

  def dashboard_graph_vote
    return dashboard_graph_vote_today if @filter_by == FilterByStats::TODAY
  end

  def dashboard_graph_vote_today
    date_range, data = dashboard_graph_vote_by_range

    {
      label: date_range,
      data: data
    }
  end

  def dashboard_graph_vote_by_range(end_date = 7.day.ago.to_date)
    date_range = end_date..Date.current
    data = date_range.map do |date|
      vote_count_by_date(date)
    end

    label = date_range.map do |date|
      date.to_s
    end

    [label, data]
  end

  def vote_count_by_date(date = Date.current)
    Poll.where("date(created_at + interval '7 hours') BETWEEN ? AND ?", date.beginning_of_day, date.end_of_day).size
  end
end

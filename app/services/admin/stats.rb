class Admin::Stats
  include FilterByStats
  include Admin::Private::Stats

  def initialize(options ={})
    @filter_by = options[:filter_by] || TODAY
  end

  def dashboard
    {
      vote: dashboard_vote,
      poll: dashboard_poll,
      user: dashboard_user
    }
  end

  def dashboard_poll
    {
      count: 302,
      graph: nil
    }
  end

  def dashboard_user
    {
      count: 1024,
      graph: nil
    }
  end

  def poll_today
    Poll.unscoped.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
  end
end

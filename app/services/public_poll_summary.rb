class PublicPollSummary
  def initialize
    
  end

  ## public brand + celebrity

  def get_poll_public_brand_celebrity
    poll_citizen = "member_type = 'Celebrity' OR member_type = 'Brand'"
    {
      today: poll_public_all(Date.current, Date.current, poll_citizen).count,
      yesterday: poll_public_all(1.days.ago.to_date, 1.days.ago.to_date, poll_citizen).count,
      week_ago: poll_public_all(7.days.ago.to_date, Date.current, poll_citizen).count,
      month_ago: poll_public_all(30.days.ago.to_date, Date.current, poll_citizen).count
    }
  end

  def get_poll_public_brand_celebrity_total
    poll_public_all_total("member_type = 'Celebrity' OR member_type = 'Brand'").count
  end


  ## public citizen

  def get_poll_public_citizen
    poll_citizen = "member_type = 'Citizen'"
    {
      today: poll_public_all(Date.current, Date.current, poll_citizen).count,
      yesterday: poll_public_all(1.days.ago.to_date, 1.days.ago.to_date, poll_citizen).count,
      week_ago: poll_public_all(7.days.ago.to_date, Date.current, poll_citizen).count,
      month_ago: poll_public_all(30.days.ago.to_date, Date.current, poll_citizen).count
    }
  end

  def get_poll_public_citizen_total
    poll_public_all_total("member_type = 'Citizen'").count
  end

  ## public all ##
  
  def get_poll_public_all
    {
      today: poll_public_all(Date.current).count,
      yesterday: poll_public_all(1.days.ago.to_date, 1.days.ago.to_date).count,
      week_ago: poll_public_all(7.days.ago.to_date).count,
      month_ago: poll_public_all(30.days.ago.to_date).count
    }
  end

  def get_poll_public_all_total
    poll_public_all_total.count
  end

  private

  def poll_public_all(end_date, start_date = Date.current, query_options = nil)
    @query = Poll.where("public = 't' AND date(created_at + interval '7 hours') BETWEEN ? AND ?", end_date, start_date).where(query_options)
    @query
  end

  def poll_public_all_total(query_options = nil)
    Poll.where("public = 't'").where(query_options)
  end

  
end
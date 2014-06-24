module PollHelper
  include ActionView::Helpers::NumberHelper

  def convert_to_percent(vote, vote_all)
    number_to_percentage((vote*100)/vote_all.to_f, precision: 0)
  end

  # def polls_30_days_ago_chart(start = 1.month.ago)
  #   polls_by_day = Poll.total_grouped_by_date(start)
    
  #   polls_friend_by_day = Poll.where("public = ? AND in_group_ids = ?", false, '0').total_grouped_by_date(start)

  #   polls_public_by_day = Poll.where("public = 't'").total_grouped_by_date(start)

  #   polls_group_by_day = Poll.where("public = ? AND in_group_ids != ?", false, '0').total_grouped_by_date(start)

  #   (start.to_date..Date.today).map do |date|
  #     {
  #       created_at: date,
  #       count: polls_by_day[date] || 0,
  #       poll_of_friend: polls_friend_by_day[date] || 0,
  #       poll_of_public: polls_public_by_day[date] || 0,
  #       poll_of_group: polls_group_by_day[date] || 0
  #     }
  #   end

  # end

  def polls_30_days_ago_chart(start = 1.month.ago)
    (start.to_date..Date.current).map do |date|
      @query = Poll.unscoped.where("date(created_at) = ?", date).to_a
      {
        created_at: date,
        count: @query.count,
        poll_of_friend: @query.select{ |e| e.public == false && e.in_group_ids == '0' }.compact.count,
        poll_of_public: @query.select{ |e| e.public == true }.compact.count,
        poll_of_group: @query.select{ |e| e.public == false && e.in_group_ids != '0' }.compact.count
      }
    end
  end

  def number_of_polls_created_today_chart
    query = Poll.unscoped.where("date(created_at) = ?", Date.current).group("date_part('hour', created_at)", "polls.id").count
    new_hash = {}

    query.map do |k,v| 
      query_hash = { hours: (k[0] + 7).to_i, count: v }
      new_hash.merge(query_hash)
    end
    
    new_hash
  end

  
end

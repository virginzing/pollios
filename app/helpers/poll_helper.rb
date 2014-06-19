module PollHelper
  include ActionView::Helpers::NumberHelper

  def convert_to_percent(vote, vote_all)
    number_to_percentage((vote*100)/vote_all.to_f, precision: 0)
  end

  def polls_30_days_ago_chart(start = 1.month.ago)
    polls_by_day = Poll.total_grouped_by_date(start)
    
    polls_friend_by_day = Poll.where("public = ? AND in_group_ids = ?", false, '0').total_grouped_by_date(start)

    polls_public_by_day = Poll.where("public = 't'").total_grouped_by_date(start)

    polls_group_by_day = Poll.where("public = ? AND in_group_ids != ?", false, '0').total_grouped_by_date(start)

    (start.to_date..Date.today).map do |date|
      {
        created_at: date,
        count: polls_by_day[date] || 0,
        poll_of_friend: polls_friend_by_day[date] || 0,
        poll_of_public: polls_public_by_day[date] || 0,
        poll_of_group: polls_group_by_day[date] || 0
      }
    end
  end

  
end

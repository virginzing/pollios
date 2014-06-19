module PollHelper
  include ActionView::Helpers::NumberHelper

  def convert_to_percent(vote, vote_all)
    number_to_percentage((vote*100)/vote_all.to_f, precision: 0)
  end

  def polls_30_days_ago
    (1.months.ago.to_date..Date.today).map do |date|
      {
        created_at: date,
        count: Poll.where("date(created_at) = ?", date).count
      }
    end
  end

  
end

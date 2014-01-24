module PollHelper
  include ActionView::Helpers::NumberHelper

  def convert_to_percent(vote, vote_all)
    number_to_percentage((vote*100)/vote_all.to_f, precision: 0)
  end
  
end

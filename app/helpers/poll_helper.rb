module PollHelper
  include ActionView::Helpers::NumberHelper

  def convert_to_percent(vote, vote_all)
    number_to_percentage((vote*100)/vote_all.to_f, precision: 0)
  end

  def check_my_shared(my_shared_ids, poll_id)
    if my_shared_ids.include?(poll_id)
      Hash["shared" => true]
    else
      Hash["shared" => false]
    end
  end
  
end

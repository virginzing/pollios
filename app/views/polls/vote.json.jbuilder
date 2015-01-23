if @poll.present?
  json.response_status "OK"
  json.information @poll.slice("view_all","vote_all","expire_date").values.map! {|value| value.to_i }
  json.scroll @poll.get_choice_scroll
  json.vote_max @poll.get_vote_max

  # if @poll.campaign_id != 0
  #   json.feedback_message @message
  # end

else
  json.response_status "ERROR"
  json.response_message "Voted Already."
end
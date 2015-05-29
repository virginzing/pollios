if @poll.present?
  json.response_status "OK"
  json.information @poll.reload.slice("view_all","vote_all","expire_date").values.map! {|value| value.to_i }
  json.scroll @poll.get_choice_scroll
  json.vote_max @poll.get_vote_max_no_cached

  json.choices @poll.choices do |choice|
    json.choice_id choice.id
    json.answer choice.answer
    json.vote choice.vote
  end

  if @reward
    json.reward_info @reward.as_json
  end

else
  json.response_status "ERROR"
  json.response_message "Voted Already."
end
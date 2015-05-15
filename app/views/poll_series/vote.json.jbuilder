if @votes.present?
  json.response_status "OK"
  if @reward
    json.reward_info @reward.as_json
  end
else
  json.response_status "ERROR"
  json.response_message "Voted Already."
end
json.response_status "OK"
json.list_reward @rewards do |reward|
  json.campaign reward.campaign.as_json()

  json.reward_info reward.as_json()
  
  if reward.poll_id.present?
    json.poll do
      json.id reward.poll.id
      json.title reward.poll.title
    end
  else
    json.questionnaire do
      json.id reward.poll_series.id
      json.title reward.poll_series.description
    end
  end

end

json.next_cursor @next_cursor

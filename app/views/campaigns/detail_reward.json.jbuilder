json.response_status "OK"
json.campaign_detail reward.campaign.as_json()

json.reward_info reward.as_json()

if reward.poll_id.present?
  json.poll do
    json.id reward.poll.id
    json.title reward.poll.title
  end
elsif reward.poll_series_id.present?
  json.questionnaire do
    json.id reward.poll_series.id
    json.title reward.poll_series.description
  end
end
if @rewards
  json.response_status "OK"
  json.list_reward @rewards do |reward|
  json.campaign do
    json.id reward.campaign.id
    json.name reward.campaign.name
    json.photo_campaign reward.campaign.photo_campaign.url(:thumbnail)
    json.expire reward.campaign.expire.to_i
  end
  json.serial_code reward.serial_code
  end
else
  json.response_message "ERROR"
end
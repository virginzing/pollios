json.response_status "OK"
json.list_reward @rewards do |reward|
  json.campaign do
    json.id reward.campaign.id
    json.name reward.campaign.name.presence || ""
    json.description reward.campaign.description.presence || ""
    json.how_to_redeem reward.campaign.how_to_redeem.presence || ""
    json.photo_campaign reward.campaign.get_photo_campaign
    json.expire reward.campaign.expire.to_i
    json.serial_code reward.serial_code
    json.redeem reward.redeem
    json.redeem_at reward.redeem_at.present? ? reward.redeem_at.to_i : ""
  end
  json.poll do
    json.id reward.poll.id
    json.title reward.poll.title
  end
end
json.next_cursor @next_cursor

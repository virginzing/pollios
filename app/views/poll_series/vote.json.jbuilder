if @votes.present?
  json.response_status "OK"

  if @campaign_member.present?
    json.campaign @campaign_member.campaign.as_json()
    json.lucky_info @campaign_member.as_json()
  else
    json.response_message @message || ""
  end

else
  json.response_status "ERROR"
  json.response_message "Voted Already."
end
if @rewards
  json.response_status "OK"
  json.list_reward @rewards do |reward|

  json.campaign do
    json.id reward.campaign.id
    json.description reward.campaign.name
    json.photo_campaign reward.campaign.photo_campaign.url(:thumbnail)
    json.expire reward.campaign.expire.to_i
    json.serial_code reward.serial_code
    json.creator do
      json.member_id reward.campaign.member.id
      json.type reward.campaign.member.member_type_text
      json.name reward.campaign.member.sentai_name
      json.username reward.campaign.member.username
      json.avatar reward.campaign.member.get_avatar
      json.email reward.campaign.member.email
    end
  end

    json.poll do
      json.id reward.campaign.poll.id
      json.title reward.campaign.poll.title
      json.vote_count reward.campaign.poll.vote_all
      json.view_count reward.campaign.poll.view_all
      json.expire_date reward.campaign.poll.expire_date.to_i
      json.created_at reward.campaign.poll.created_at.to_i
      json.voted_detail @current_member.list_voted?(@history_voted, reward.campaign.poll.id)
      json.viewed @current_member.list_viewed?(@history_viewed, reward.campaign.poll.id)
      json.choice_count reward.campaign.poll.choice_count
      json.series reward.campaign.poll.series
      json.tags reward.campaign.poll.cached_tags
      # json.campaign reward.campaign.poll.get_campaign
      json.share_count reward.campaign.poll.share_count
      json.is_public reward.campaign.poll.public
    end

  end
  json.next_cursor @next_cursor
else
  json.response_message "ERROR"
end
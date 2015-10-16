def construct_messasge_for(notify_log)

  properties = notify_log.custom_properties
  if properties[:type] == "Poll"
    sender = notify_log.sender.fullname
    if properties[:action] == "Vote" || properties[:action] == "Create"
      if properties[:anonymous] == true
        sender = "Anonymous"
      end

      if properties[:action] == "Vote"
        action = "voted on"
      else
        action = "asked"
      end

      return "#{sender} #{action} #{properties[:poll][:title]}"
    end

    return notify_log.message
  else
    return notify_log.message
  end
end

if @notifications
  json.response_status "OK"
  
  json.notify @notifications do |notify|
    json.notify_id notify.id

    if notify.sender.nil?
      json.sender System::DefaultMember.new.to_json  
    else
      json.sender do
        json.partial! 'response_helper/member/short_info_feed', member: notify.sender
      end
    end

    # if notify.custom_properties[:poll].present?
    #   json.message notify.custom_properties[:poll][:title]
    # else
      json.message construct_messasge_for(notify)
    # end

    json.custom_properties notify.custom_properties
    json.created_at notify.created_at.to_i
  end

  json.total_entries @total_entries
  json.next_cursor @next_cursor
else
  json.response_status "ERROR"
end

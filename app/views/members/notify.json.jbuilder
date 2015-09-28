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

    json.message notify.message
    json.custom_properties notify.custom_properties
    json.created_at notify.created_at.to_i
  end

  json.total_entries @total_entries
  json.next_cursor @next_cursor
else
  json.response_status "ERROR"
end
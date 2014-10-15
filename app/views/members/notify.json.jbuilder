if @notify
  json.response_status "OK"
  json.request @current_member.request_count
  json.notify @current_member.notification_count

  json.notify @notify do |notify|
    json.sender do
      json.partial! 'response_helper/member/short_info_feed', member: notify.sender
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
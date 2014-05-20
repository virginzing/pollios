if @notify
  json.response_status "OK"
  json.notify @notify do |notify|
    json.sender notify.sender
    json.message notify.message
    json.custom_properties notify.custom_properties
    json.created_at notify.created_at.to_i
  end

  json.total_entries @total_entries
  json.next_cursor @next_cursor
else
  json.response_status "ERROR"
end
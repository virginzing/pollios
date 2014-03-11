if @hide
  json.response_status "OK"
else
  json.response_status "ERROR"
  json.response_message @hide.errors.full_messages
end
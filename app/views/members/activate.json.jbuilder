if @activate
  json.response_status "OK"
  json.response_message @invite_code[:message]
else
  json.response_status "ERROR"
  json.response_message @invite_code[:message]
end
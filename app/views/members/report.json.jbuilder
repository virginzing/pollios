if @current_member && @find_friend
  json.response_status "OK"
else
  json.response_status "ERROR"
  json.response_message @error_message
end
if @friend
  json.response_status "OK"
else
  json.response_status "ERROR"
  json.response_message "Cannot block your friend."
end
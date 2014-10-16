if @new_request
  json.response_status "OK"
else
  json.response_status "ERROR"
  json.response_message "You've already requested this group."
end
if @new_request
  json.response_status "OK"

  if @joined
    json.waitting_approve false
    json.join_success true
    json.response_message "Join group successfully"
  else
    json.join_success false
    json.waitting_approve true
    json.response_message "Waiting approve"
  end

else
  json.response_status "OK"
  json.join_success false
  json.response_message "Waiting approve"
end

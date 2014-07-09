if @request
  json.response_status "OK"
  if @new_request
    json.response_message "Request Successfully."
  else
    json.response_message "You already sent request."
  end
else
  json.response_status "ERROR"
end
if @poll
  json.response_status "OK"
else
  json.response_status "ERROR"
  json.response_message "ERROR"
end
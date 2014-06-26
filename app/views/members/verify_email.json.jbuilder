if @verify_email
  json.response_status "OK"
  json.response_message "Found"
else
  json.response_status "ERROR"
  json.response_message "Not found"
end
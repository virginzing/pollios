if @invite_user_via_email
  json.response_status "OK"
else
  json.response_status "ERROR"
  json.response_message "Something went wrong"
end
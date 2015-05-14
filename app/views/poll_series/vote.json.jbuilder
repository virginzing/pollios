if @votes.present?
  json.response_status "OK"
else
  json.response_status "ERROR"
  json.response_message "Voted Already."
end
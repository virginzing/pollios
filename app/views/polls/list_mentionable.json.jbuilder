if @poll
  json.response_status "OK"
  json.list_mentionable @list_mentionable
else
  json.response_status "ERROR"
  json.response_message "Something went wrong"
end
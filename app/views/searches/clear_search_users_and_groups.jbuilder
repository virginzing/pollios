if @clear_search_users_and_groups
  json.response_status "OK"
else
  json.response_status "ERROR"
  json.response_message "Something went wrong, please try again."
end
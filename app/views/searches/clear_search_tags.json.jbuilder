if @clear_search_tags
  json.response_status "OK"
else
  json.response_status "ERROR"
  json.response_message "Something went wrong, please try again."
end
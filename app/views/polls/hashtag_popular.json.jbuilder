if @tag_lists
  json.response_status "OK"
  json.tag_lists @tag_lists
else
  json.response_status "ERROR"
  json.response_message "Unable load."
end
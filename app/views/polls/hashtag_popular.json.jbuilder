if @tag_lists
  json.response_status "OK"
  json.tag_lists @tag_lists
  json.recent_search_tags @recent_search_tags
else
  json.response_status "ERROR"
  json.response_message "Unable load."
end
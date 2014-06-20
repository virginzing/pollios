if @activity_items
  json.response_status "OK"
  json.activity @activity_items
else
  json.response_status "ERROR"
  json.response_message "Not activity yet."
end
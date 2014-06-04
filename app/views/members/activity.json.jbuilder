if @activity.present?
  json.response_status "OK"
  json.activity @activity.items
else
  json.response_status "ERROR"
  json.response_message "Not activity yet."
end
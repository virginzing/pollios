if @stats_all
  json.response_status "OK"
  json.stats @stats_all
else
  json.response_status "ERROR"
  json.response_message "ERROR"
end
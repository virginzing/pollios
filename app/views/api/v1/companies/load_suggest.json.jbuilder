if @suggests
  json.response_status "OK"
  json.suggests @suggests_as_json
  json.total_entries @total_entries
  json.next_cursor @next_cursor
else
  json.response_status "ERROR"
end
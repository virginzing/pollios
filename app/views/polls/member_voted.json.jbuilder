if @history_votes_show_result
  json.response_status "OK"

  json.member_voted_show_result @list_history_votes_show_result

  json.total_show_result @total_history_votes_show_result

  json.next_cursor @next_cursor
else
  json.response_status "ERROR"
  json.response_message @response_message
end
if @polls
  json.response_status "OK"
  json.surveyor_polls @polls, partial: 'response_helper/surveyor/list_polls', as: :poll
  # json.total_entries @total_entries
  # json.next_cursor @next_cursor
else
  json.response_status "ERROR"
end
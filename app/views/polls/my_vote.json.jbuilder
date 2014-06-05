if @poll_nonseries
  json.response_status "OK"
    json.count do
      json.vote @current_member.cached_my_voted.count
    end

  json.poll_nonseries @poll_nonseries, partial: 'response_helper/poll/normal', as: :poll

  json.next_cursor @next_cursor
end
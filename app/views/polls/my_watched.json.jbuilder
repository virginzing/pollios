if @poll_nonseries
  json.response_status "OK"
    json.count do
      json.watched @current_member.cached_watched.count
    end

  json.poll_nonseries @poll_nonseries, partial: 'response_helper/poll/normal', as: :poll

  json.next_cursor @next_cursor
end
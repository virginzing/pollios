if @poll_nonseries
  json.response_status "OK"
    json.count do
      # json.watched @current_member.cached_watched.count
      json.in_public @init_poll.watch_public_poll
      json.in_friend_following @init_poll.watch_friend_following_poll
      json.in_group @init_poll.watch_group_poll
    end

  json.poll_nonseries @poll_nonseries, partial: 'response_helper/poll/normal', as: :poll
  json.total_entries @total_entries
  json.next_cursor @next_cursor
end
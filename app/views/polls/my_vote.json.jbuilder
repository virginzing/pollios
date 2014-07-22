if @poll_nonseries
  json.response_status "OK"
    json.count do
      # json.vote @current_member.cached_my_voted.count
      json.in_public @init_poll.vote_public_poll
      json.in_friend_following @init_poll.vote_friend_following_poll
      json.in_group @init_poll.vote_group_poll
    end

  json.poll_nonseries @poll_nonseries, partial: 'response_helper/poll/normal', as: :poll
  json.total_entries @total_entries
  json.next_cursor @next_cursor
end
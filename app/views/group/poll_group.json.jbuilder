if @polls
  json.response_status "OK"
  json.poll_nonseries @polls do |poll|
    json.creator poll.cached_member

    json.poll do
      json.id poll.id
      json.title poll.title
      json.vote_count poll.vote_all
      json.view_count poll.view_all
      json.expire_date poll.expire_date.to_i
      json.created_at poll.created_at.to_i
      json.voted_detail @current_member.list_voted?(@history_voted, poll.id)
      json.viewed @current_member.list_viewed?(@history_viewed, poll.id)
      json.choice_count poll.choice_count
      json.tags poll.cached_tags
    end

  end
  json.next_cursor @next_cursor
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end
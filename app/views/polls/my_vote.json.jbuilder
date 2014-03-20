if @poll_nonseries
  json.response_status "OK"
  json.count do
    json.vote @current_member.history_votes.where(poll_series_id: 0).count
  end

  json.poll_nonseries @poll_nonseries do |poll|
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
      json.series poll.series
      json.tags poll.cached_tags
      json.share_count poll.share_count
      json.is_public poll.public
    end
    
  end

  json.next_cursor @next_cursor
end
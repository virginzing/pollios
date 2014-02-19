if @poll_series || @poll_nonseries

  json.response_status "OK"
  
  json.poll_series @poll_series do |poll|
    json.creator do
      json.id poll.member_id
      json.type poll.member.member_type_text
      json.name poll.member.sentai_name
      json.username poll.member.username
      json.avatar poll.member.avatar.present? ? poll.member.avatar : "No Image"
    end

    json.list_of_poll do
      json.id poll.poll_series_id
      json.vote_count poll.poll_series.vote_all
      json.view_count poll.poll_series.view_all
      json.expire_date poll.poll_series.expire_date.to_i
      json.created_at poll.poll_series.created_at.to_i
      json.title poll.poll_series.description
      json.choice_count poll.choice_count
      json.series poll.series
      json.tags poll.poll_series.cached_tags

      json.poll poll.find_poll_series(poll.member_id, poll.poll_series_id) do |poll|
        json.id poll.id
        json.title poll.title
        json.vote_count poll.vote_all
        json.view_count poll.view_all
        json.expire_date poll.expire_date.to_i
        json.voted_detail @current_guest.list_voted?(@history_voted_guest, poll.id)
        json.viewed @current_guest.list_viewed?(@history_viewed_guest, poll.id)
      end
    end
  end

  json.poll_nonseries @poll_nonseries do |poll|
    json.creator do
      json.id poll.member_id
      json.type poll.member.member_type_text
      json.name poll.member.sentai_name
      json.username poll.member.username
      json.avatar poll.member.avatar.present? ? poll.member.avatar : "No Image"
    end

    json.poll do
      json.id poll.id
      json.title poll.title
      json.vote_count poll.vote_all
      json.view_count poll.view_all
      json.expire_date poll.expire_date.to_i
      json.created_at poll.created_at.to_i
      json.voted_detail @current_guest.list_voted?(@history_voted_guest, poll.id)
      json.viewed @current_guest.list_viewed?(@history_viewed_guest, poll.id)
      json.choice_count poll.choice_count
      json.series poll.series
      json.tags poll.cached_tags
    end
  end
  json.next_cursor @next_cursor

end

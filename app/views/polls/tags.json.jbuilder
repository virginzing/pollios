if @find_tag.nil?
  json.response_status "ERROR"
  json.response_message "No Found."
else
  json.response_status "OK"
  json.poll_nonseries @poll do |poll|
    json.creator do
      json.member_id poll.member_id
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
      json.voted_detail @current_member.list_voted?(@history_voted, poll.id)
      json.viewed @current_member.list_viewed?(@history_viewed, poll.id)
      json.choice_count poll.choice_count
      json.series poll.series
      json.tags poll.cached_tags
    end
  end
  json.next_cursor @next_cursor

end

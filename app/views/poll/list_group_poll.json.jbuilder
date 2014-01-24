if @poll.present?
  json.response_status "OK"
  json.data @poll do |poll|
    json.friend_id poll.member_id
    json.poll_id poll.id
    json.title poll.title
    json.expire_date poll.expire_date
    json.vote_all poll.vote_all
    json.view_all poll.view_all
    json.created_at poll.created_at
    json.created_by poll.member_username
    json.updated_at poll.updated_at
  end
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end
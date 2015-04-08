json.response_status "OK"

json.list_polls @list_polls do |poll|
  json.creator poll.member.as_json
  json.poll_id poll.id
  json.title poll.title
  json.photo poll.get_photo
  json.thumbnail_type poll.thumbnail_type || 0
  json.vote_count poll.vote_all
  json.view_count poll.view_all
  json.comment_count poll.comment_count 
  json.report_count poll.report_count
  json.expire_date poll.expire_date.to_i
  json.created_at poll.created_at.to_i
  json.type_poll poll.type_poll
  json.is_public poll.public
end

json.next_cursor @next_cursor
json.total_entries @total_entries


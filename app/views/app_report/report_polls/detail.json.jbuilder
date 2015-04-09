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
json.original_images poll.get_original_images if poll.photo_poll.present?
json.choices poll.cached_choices do |choice|
  json.choice_id choice.id
  json.answer choice.answer
  json.vote choice.vote
end

json.list_reason @list_reason do |reason|
  json.reporter reason.member.as_json
  json.message reason.message
  json.message_preset reason.message_preset
end
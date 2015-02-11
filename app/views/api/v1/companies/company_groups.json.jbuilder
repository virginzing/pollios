if @groups
  json.response_status "OK"
  json.groups @groups do |group|
    json.id group.id
    json.name group.name
    json.photo group.get_photo_group
    json.member_count group.get_all_member_count
    json.poll_count group.get_all_poll_count   ## amount total of member don't vote poll in group
    json.description group.get_description
    json.public group.public
    json.created_at group.created_at.to_i
    json.leave_group group.leave_group
    json.public_id group.get_public_id
    json.group_type group.group_type
  end
else
  json.response_status "ERROR"
  json.response_message "ERROR"
end
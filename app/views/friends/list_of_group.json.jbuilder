if @groups
  json.response_status "OK"
  json.groups @groups do |group|
    json.id group.id
    json.name group.name
    json.photo group.get_photo_group
    json.member_count group.member_in_group
    json.poll_count group.poll_count
    json.description group.get_description
    json.public group.public
    json.created_at group.created_at.to_i
  end
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end
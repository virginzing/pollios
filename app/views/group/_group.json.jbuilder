if @group.present?
  json.response_status "OK"
  json.group_id @group.id
  json.name_group @group.name
  json.photo_group @group.photo_group.url(:thumbnail)
  json.member_in_group @group.members do |member|
    json.member_id member.id
    json.name member.sentai_name
    json.username member.username
    json.email member.email
    json.avatar member.avatar.present? ? member.avatar : "No Image"
  end
else
  json.response_status "ERROR"
  json.response_message "Unable.."
end

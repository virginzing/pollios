if @group.present?
  json.response_status "OK"
  json.partial! 'group/group_detail', group: @group
  json.member_active @group.get_member_active do |member|
    json.member_id member.id
    json.sentai_name member.sentai_name
    json.username member.username
    json.email member.email
    json.avatar member.avatar.present? ? member.avatar : "No Image"
  end
  json.member_inactive @group.get_member_inactive do |member|
    json.member_id member.id
    json.sentai_name member.sentai_name
    json.username member.username
    json.email member.email
    json.avatar member.avatar.present? ? member.avatar : "No Image"
  end
else
  json.response_status "ERROR"
  json.response_message "Unable.."
end

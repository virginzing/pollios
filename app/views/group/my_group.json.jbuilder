if @group_active || @group_inactive
  json.response_status "OK"
  json.my_group @group_active do |group|
    json.id group.id
    json.name group.name
    json.photo group.get_photo_group
    json.cover group.get_cover_group
    json.member_count hash_member_count[group.id] || 0
    json.description group.get_description
    json.public group.public
    json.leave_group group.leave_group
    json.created_at group.created_at.to_i
    json.admin_post_only group.get_admin_post_only
    json.need_approve group.need_approve
    json.as_admin group.member_admin
    json.public_id group.get_public_id
    json.group_type group.group_type
  end
  json.group_request @group_inactive, partial: 'response_helper/group/request', as: :group
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end
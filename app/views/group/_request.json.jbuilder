json.id group.id
json.name group.name
json.photo group.get_photo_group
json.member_count group.member_count
json.poll_count group.poll_count
json.description group.description
json.created_at group.created_at.to_i
json.invite_by Member.find(group.invite_id)
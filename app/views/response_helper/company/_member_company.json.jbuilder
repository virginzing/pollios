json.member_id member.id
json.name member.get_name
json.username member.get_username
json.email member.email
json.type member.member_type_text
json.description member.get_description
json.avatar member.get_avatar
json.in_group (member.groups & group_company) do |group|
  json.id group.id
  json.name group.name
  json.photo group.get_photo_group
end
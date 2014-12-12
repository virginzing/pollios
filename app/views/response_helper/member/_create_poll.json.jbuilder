json.member_id member.id
json.name member.get_name
json.type member.member_type_text
json.avatar member.get_avatar
json.status do
	json.add_friend_already false
	json.status "nofriend"
	json.following ""
end
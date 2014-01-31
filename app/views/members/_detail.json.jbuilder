json.member_id member.id
json.sentai_name member.sentai_name
json.username member.username
json.email member.email
json.avatar member.avatar.present? ? member.avatar : "No Image"
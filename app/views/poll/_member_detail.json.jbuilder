json.member_id poll.member_id
json.member_type poll.member.member_type_text
json.sentai_name poll.member.sentai_name
json.username poll.member.username
json.avatar poll.member.avatar.present? ? poll.member.avatar : "No Image"
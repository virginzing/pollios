if @groups
  json.response_status "OK"
  json.groups @groups do |group|
    json.partial! 'response_helper/group/default', group: group
    json.member_count hash_member_count[group.id] || 0
    if @find_friend.company?
      json.as_admin false
    else
      json.as_admin group.member_admin
    end
  end
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end

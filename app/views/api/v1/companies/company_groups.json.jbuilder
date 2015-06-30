if @groups
  json.response_status "OK"
  json.groups @groups do |group|
    json.partial! 'response_helper/group/default', group: group
    json.member_count group.get_all_member_count
    json.poll_count group.get_all_poll_count   ## amount total of member don't vote poll in group
  end
else
  json.response_status "ERROR"
  json.response_message "ERROR"
end

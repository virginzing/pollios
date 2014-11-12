if @groups
  json.response_status "OK"
  json.groups @groups do |group|
    json.partial! 'response_helper/group/full_info', group: group
    json.poll_count group.get_poll_not_vote_count   ## amount total of member don't vote poll in group
    json.as_admin group.check_as_admin?(@current_member)
  end
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end
if @groups
  json.response_status "OK"
  json.groups @groups do |group|
    json.partial! 'response_helper/group/full_info', group: group
    json.poll_count group.get_poll_not_vote_count   ## amount total of member don't vote poll in group
  end
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end
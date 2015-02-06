if @groups
  json.response_status "OK"
  json.groups @groups do |group|
    json.partial! 'response_helper/group/full_info', group: group
    # json.poll_count group.get_poll_not_vote_count   ## amount total of member don't vote poll in group

    if params[:member_id] == params[:friend_id]
      json.as_admin group.member_admin
    else
      json.as_admin group.check_as_admin?(Member.find(params[:friend_id]))
    end
  end
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end
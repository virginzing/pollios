if @group_recomment
  json.response_status "OK"

  json.recommendations_group @group_recomment do |group|
    json.partial! 'response_helper/group/default', group: group
  end

end
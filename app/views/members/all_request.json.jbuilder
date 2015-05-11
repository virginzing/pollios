if @current_member
  count_your_request = 0
  count_friend_request = 0
  
  json.response_status "OK"
  
  json.request @current_member.request_count
  json.notify @current_member.notification_count

  json.your_request do
    json.array! @your_request do |member|
      json.partial! 'response_helper/member/short_info_feed', member: member
      json.status @is_your_request[count_your_request]
      count_your_request += 1
    end
  end

  json.friend_request do
    json.array! @friend_request do |member|
      json.partial! 'response_helper/member/short_info_feed', member: member
      json.status @is_friend_request[count_friend_request]
      count_friend_request += 1
    end
  end

  json.group_request @group_inactive do |group|
    json.partial! 'response_helper/group/default', group: group
    json.member_count hash_member_count[group.id] || 0
  end

  json.ask_join_group @ask_join_group, partial: 'response_helper/group/full_info', as: :group
else
  json.response_status "ERROR"
end


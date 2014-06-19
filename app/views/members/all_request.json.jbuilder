if @current_member
  count_your_request = 0
  count_friend_request = 0

  json.response_status "OK"
  json.your_request do
    json.array! @your_request do |member|
      json.partial! 'response_helper/member/short_info', member: member
      json.status @is_your_request[count_your_request]
      count_your_request += 1
    end
  end

  json.friend_request do
    json.array! @friend_request do |member|
      json.partial! 'response_helper/member/short_info', member: member
      json.status @is_friend_request[count_friend_request]
      count_friend_request += 1
    end
  end

  json.group_request @group_inactive, partial: 'response_helper/group/request', as: :group
else
  json.response_status "ERROR"
end


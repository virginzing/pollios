if @current_member
  json.response_status "OK"
  json.your_request do
    json.array! @your_request do |member|
      json.partial! 'response_helper/member/short_info', member: member
    end
  end
  json.friend_request do
    json.array! @friend_request do |member|
      json.partial! 'response_helper/member/short_info', member: member
    end
  end
  json.group_request @group_inactive, partial: 'response_helper/group/request', as: :group
else
  json.response_status "ERROR"
end


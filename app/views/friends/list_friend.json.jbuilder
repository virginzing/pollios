if @friend_active
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
  json.all @friend_active do |member|
    json.partial! 'response_helper/member/short_info', member: member
  end
else
  json.response_status "ERROR"
end


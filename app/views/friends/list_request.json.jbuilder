if @your_request && @friend_request
  json.response_status "OK"
  json.your_request do
    json.array! @your_request.citizen do |member|
      json.partial! 'response_helper/member/short_info', member: member
    end
  end
  json.friend_request do
    json.array! @friend_request.citizen do |member|
      json.partial! 'response_helper/member/short_info', member: member
    end
  end
else
  json.response_status "ERROR"
end
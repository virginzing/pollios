if @your_request && @friend_request
  json.response_status "OK"
  json.your_request do
    json.array! @your_request, partial: 'members/short_detail', as: :friend
  end
  json.friend_request do
    json.array! @friend_request, partial: 'members/short_detail', as: :friend
  end
else
  json.response_status "ERROR"
end
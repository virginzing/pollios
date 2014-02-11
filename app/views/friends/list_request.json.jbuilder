if @your_request && @friend_request
  json.response_status "OK"
  json.your_request do
    json.array! @your_request, partial: 'members/detail', as: :member
  end
  json.friend_request do
    json.array! @friend_request, partial: 'members/detail', as: :member
  end
else
  json.response_status "ERROR"
end
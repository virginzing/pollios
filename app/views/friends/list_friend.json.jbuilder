if @friend_active
  json.response_status "OK"
  json.request do

  end
  json.all do
    json.array! @friend_active.citizen, partial: 'members/detail', as: :member
  end
else
  json.response_status "ERROR"
end


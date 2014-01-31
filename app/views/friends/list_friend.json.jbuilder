if @friend_active && @friend_inactive
  json.response_status "OK"
  json.citizen_active do
    json.array! @friend_active.citizen, partial: 'members/short_detail', as: :friend
  end
  json.citizen_inactive do
    json.array! @friend_inactive.citizen, partial: 'members/short_detail', as: :friend
  end
  json.celebrity do
    json.array! @friend_active.celebrity, partial: 'members/short_detail', as: :friend
  end
else
  json.response_status "ERROR"
end


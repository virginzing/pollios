if @guests.present?
  json.response_status "OK"
  json.guests do
    json.guest_id @guests.id
    json.udid     @guests.udid
    json.created_at @guests.created_at.to_i
  end
else
  json.response_status "ERROR"
end
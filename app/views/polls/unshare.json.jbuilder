if @poll.present?
  json.response_status "OK"
  json.(@poll, :share_count)
else
  json.response_status "ERROR"
  json.response_message "ERROR"
end
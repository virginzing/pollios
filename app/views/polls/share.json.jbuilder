if @shared
  json.response_status "OK"
  json.(@poll, :share_count)
else
  json.response_status "ERROR"
  json.response_message "Shared already."
end
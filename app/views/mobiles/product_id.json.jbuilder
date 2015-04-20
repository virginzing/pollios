if ENV["PRODUCT_ID_IOS_STATUS"] == "OPEN"
  json.response_status "OK"
  json.list_product_id @list_product_id
else
  json.response_status "ERROR"
  json.error_message "In-App Purchases has closed down"
end
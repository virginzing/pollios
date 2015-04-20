if ENV["PRODUCT_ID_IOS_STATUS"] == "OPEN"
  json.response_status "OK"
  json.product_id ENV["PRODUCT_ID_IOS"]
else
  json.response_status "ERROR"
  json.error_message "In-App Purchases has closed down"
end
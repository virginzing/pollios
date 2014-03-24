if @predict.first.present?
  json.response_status "OK"
else
  json.response_status "ERROR"
  json.response_message @predict.last
end
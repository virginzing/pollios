if @un_see_questionnaire
  json.response_status "OK"
else
  json.response_status "ERROR"
  json.response_message @response_message
end
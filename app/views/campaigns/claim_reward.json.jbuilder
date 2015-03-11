 if @claim
   json.response_status "OK"
   json.response_message "Success"
 else
   json.response_status "ERROR"
   json.response_message "Please try again"
 end
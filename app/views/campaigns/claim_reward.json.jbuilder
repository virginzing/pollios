 if @claim
   json.response_status "OK"
   json.partial! 'response_helper/member/full_info', member: @current_member
   json.reward_info @member_reward.as_json
   json.response_message "Success"
 else
   json.response_status "ERROR"
   json.response_message "Please try again"
 end
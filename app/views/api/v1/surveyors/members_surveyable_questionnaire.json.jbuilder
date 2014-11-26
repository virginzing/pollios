if @members_surveyable || @members_voted

  json.response_status "OK"
  json.members_surveyable @members_surveyable, partial: 'response_helper/company/member_company', as: :member
  json.members_voted @members_voted, partial: 'response_helper/company/member_company', as: :member
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end
if @members
  json.response_status "OK"
  json.member_company @members, partial: 'response_helper/company/member_company', as: :member
else
  json.response_status "ERROR"
  json.response_message "Unable..."
end
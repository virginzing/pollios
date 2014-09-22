if @polls
  json.response_status "OK"
  json.company_polls @polls, partial: 'response_helper/company/list_company_polls', as: :poll
else
  json.response_status "ERROR"
end
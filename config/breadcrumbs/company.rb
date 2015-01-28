crumb :company_polls do
  link "All Polls", company_polls_path
end

crumb :company_new_poll do
  link "New Poll"
  parent :company_polls
end

crumb :company_poll_detail do |poll|
  link poll.title, company_polls_detail_path(poll)
  parent :company_polls
end

crumb :company_questionnaires do
  link "All Questionnaires", company_questionnaires_path
end
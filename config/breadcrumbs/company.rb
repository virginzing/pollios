crumb :company_polls do
  link "All Polls", company_polls_path
end

crumb :company_new_poll do
  link "New Poll"
  parent :company_polls
end
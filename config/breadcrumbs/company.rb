crumb :company_polls do
  link "All Polls", company_polls_path
end


## polls ##

crumb :company_new_group_poll do
  link "New Group poll"
  parent :company_polls
end

crumb :company_new_public_poll do
  link "New Public poll"
  parent :company_polls
end

crumb :company_poll_detail do |poll|
  link truncate(poll.title), company_poll_detail_path(poll)
  parent :company_polls
end

crumb :company_edit_poll do |poll|
  link "Edit", company_edit_poll_path(poll)
  parent :company_poll_detail, poll
end



## questionnaires ##

crumb :company_questionnaires do
  link "All Questionnaires", company_questionnaires_path
end
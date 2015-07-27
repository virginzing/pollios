crumb :public_survey_polls do
  link "All Polls", public_survey_polls_path
end

crumb :public_survey_poll_new do
  link "New Public poll"
  parent :public_survey_polls
end

## polls ##

# crumb :company_new_group_poll do
#   link "New Group poll"
#   parent :company_polls
# end

# crumb :company_poll_detail do |poll|
#   link truncate(poll.title), company_poll_detail_path(poll)
#   parent :company_polls
# end

# crumb :company_edit_poll do |poll|
#   link "Edit", company_edit_poll_path(poll)
#   parent :company_poll_detail, poll
# end



## questionnaires ##

# crumb :company_questionnaires do
#   link "All Questionnaires", company_questionnaires_path
# end

# crumb :company_questionnaire_detail do |questionnnaire|
#   link truncate(questionnnaire.description), company_questionnaire_detail_path(questionnnaire)
#   parent :company_questionnaires
# end

# crumb :company_edit_questionnaire do |questionnnaire|
#   link "Edit", company_edit_questionnaire_path(questionnnaire)
#   parent :company_questionnaire_detail, questionnnaire
# end

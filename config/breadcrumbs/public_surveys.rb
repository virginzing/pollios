## polls ##

crumb :public_survey_polls do
  link "All Polls", public_survey_polls_path
end

crumb :new_public_survey_poll do
  link "New Public poll"
  parent :public_survey_polls
end

crumb :public_survey_poll do |poll|
  link truncate(poll.title), public_survey_poll_path(poll)
  parent :public_survey_polls
end

crumb :edit_public_survey_poll do |poll|
  link truncate(poll.title), public_survey_poll_path(poll)
  parent :public_survey_polls
end

## feedbacks ##

crumb :public_survey_feedbacks do
  link "All Feedbacks", public_survey_feedbacks_path
end

crumb :new_public_survey_feedback do
  link "New Feedback"
  parent :public_survey_feedbacks
end

crumb :public_survey_feedback do |feedback|
  link truncate(feedback.description), public_survey_feedback_path(feedback)
  parent :public_survey_feedbacks
end

crumb :edit_public_survey_feedback do |feedback|
  link truncate(feedback.description), public_survey_feedback_path(feedback)
  parent :public_survey_feedbacks
end


## groups ##

crumb :public_survey_groups do
  link "All Groups", public_survey_groups_path
end

crumb :new_public_survey_group do
  link "New Group"
  parent :public_survey_groups
end

crumb :new_poll_public_survey_group do
  link "New poll to group"
  parent :public_survey_groups
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

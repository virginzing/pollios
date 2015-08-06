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
  link "All Questionnaires & Feedbacks", company_questionnaires_path
end

crumb :new_company_questionnaire do
  link "New Questionnaires & Feedback"
  parent :company_questionnaires
end

crumb :company_questionnaire_detail do |questionnnaire|
  link truncate(questionnnaire.description), company_questionnaire_detail_path(questionnnaire)
  parent :company_questionnaires
end

crumb :company_edit_questionnaire do |questionnnaire|
  link "Edit", company_edit_questionnaire_path(questionnnaire)
  parent :company_questionnaire_detail, questionnnaire
end


## members ##

crumb :internal_survey_members do
  link "All Members", company_members_path
end

crumb :new_surveyor_internal_survey_member do
  link "New Surveyor"
  parent :internal_survey_members
end

crumb :new_member_internal_survey_member do
  link "New Members"
  parent :internal_survey_members
end

## groups ##

crumb :internal_survey_groups do
  link "All Groups", company_groups_path
end

crumb :new_internal_survey_group do
  link "New Group"
  parent :internal_survey_groups
end

crumb :internal_survey_group do |group|
  link truncate(group.name), company_group_detail_path(group)
  parent :internal_survey_groups
end

crumb :edit_internal_survey_group do |group|
  link truncate(group.name), company_edit_group_path(group)
  parent :internal_survey_group, group
end

## campaigns ##

crumb :internal_survey_campaigns do
  link "All Campaigns", company_campaigns_path
end

crumb :new_internal_survey_campaign do
  link "New Campaign"
  parent :internal_survey_campaigns
end

crumb :internal_survey_campaign do |campaign|
  link truncate(campaign.name), company_campaign_detail_path(campaign)
  parent :internal_survey_campaigns
end

crumb :edit_internal_survey_campaign do |campaign|
  link "Edit"
  parent :internal_survey_campaign, campaign
end

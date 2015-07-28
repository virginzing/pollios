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
  link "Edit"
  parent :public_survey_poll, poll
end

crumb :campaign_public_survey_poll do |poll|
  link "Campaign"
  parent :public_survey_poll, poll
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
  link "Edit"
  parent :public_survey_feedback, feedback
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

crumb :public_survey_group do |group|
  link truncate(group.name), public_survey_group_path(group)
  parent :public_survey_groups
end

crumb :edit_public_survey_group do |group|
  link "Edit"
  parent :public_survey_group, group
end


## campaings ##

crumb :public_survey_campaigns do
  link "All Campaigns", public_survey_campaigns_path
end

crumb :new_public_survey_campaign do
  link "New Campaign"
  parent :public_survey_campaigns
end

crumb :public_survey_campaign do |campaign|
  link truncate(campaign.name), public_survey_campaign_path(campaign)
  parent :public_survey_campaigns
end

crumb :edit_public_survey_campaign do |campaign|
  link "Edit"
  parent :public_survey_campaign, campaign
end


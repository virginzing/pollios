crumb :root do
  link "Home", root_path
end

crumb :new_poll do
  link "New Poll", new_poll_path
end

crumb :binary_poll do
  link "Binary Poll"
  parent :new_poll
end

crumb :freeform_poll do
  link "Freeform Poll"
  parent :new_poll
end

crumb :rating_poll do
  link "Rating Poll"
  parent :new_poll
end

crumb :polls do
  link "All Poll",  polls_path
end

crumb :poll do |poll|
  link poll.title , poll
  parent :polls
end

crumb :questionnaire do |poll_series|
  link "New Questionnaire"
end

crumb :normal_quesitonnaire do |normal_series|
  link "Normal"
  parent :questionnaire
end

crumb :same_choice_questionnaire do |same_choice_series|
  link "Same choice"
  parent :questionnaire
end


crumb :new_recurring do |new_recurring|
  link "New Recurring"
end

crumb :edit_recurring do |edit_recurring|
  link "Edit Recurring"
end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).
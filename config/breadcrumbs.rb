crumb :collections do
  link "All questionnnaires", feedback_questionnaires_path
end

crumb :collection do |collection|
  link collection.title, collection_feedback_questionnaire_path(collection)
  parent :collections
end

crumb :questionnaire do |questionnaire|
  link questionnaire.branch.name, collection_feedback_branch_detail_path(questionnaire.collection_poll, questionnaire.branch, questionnaire)
  parent :collection, questionnaire.collection_poll
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
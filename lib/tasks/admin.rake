namespace :admin do
  desc "create admin"
  task create: :environment do
    Admin.create!(email: "admin@code-app.com", password: "mefuwfhfu", password_confirmation: "mefuwfhfu")
  end

end

namespace :member do
  desc "force update member no name to use email name"
  task update_name: :environment do
    Member.where(fullname: nil).map do |member|
      member.update!(fullname: member.email.split('@').first)
    end
  end
end
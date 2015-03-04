namespace :admin do
  desc "create admin"
  task create: :environment do
    Admin.create!(email: "admin@code-app.com", password: "mefuwfhfu", password_confirmation: "mefuwfhfu")
  end

  desc "update follow pollios"
  task follow_pollios: :environment do
    Member.all.each do |member|
      find_pollios = Member.find_by_email("pollios@gmail.com")

      find_used_follow_pollios = Friend.where(follower_id: member.id, followed_id: find_pollios.id, following: false).having_status(:friend).first

      if find_pollios.present?
        if find_used_follow_pollios.present?
          find_used_follow_pollios.update(following: true)
        else
          unless Friend.where(follower_id: member.id, followed_id: find_pollios.id, following: true).first.present?
            Friend.create!(follower_id: member.id, followed_id: find_pollios.id, status: :nofriend, following: true) unless member.id == find_pollios.id
          end
        end
      end

    end
  end

  desc "Update synce facebook"
  task :sync_facebook => :environment do
    Member.all.each do |member|
      if member.providers.where(name: 'facebook').present?
        member.update(sync_facebook: true)
      end
    end
  end


  desc "Create sidekiq cron job"
  task :create_sidekiq_cron => :environment do
    Sidekiq::Cron::Job.create(name: "SavePollWorker - every at 18:00", cron: '0 18 * * *', klass: 'SavePollWorker')
    Sidekiq::Cron::Job.create(name: "RecurringPollWorker - each hourly", cron: '0 * * * *', klass: 'RecurringPollWorker')
  end

end
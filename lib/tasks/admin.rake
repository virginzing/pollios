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
    Sidekiq::Cron::Job.create(name: "SavePollWorker - every at 19:00", cron: '0 12 * * *', klass: 'SavePollWorker')
    Sidekiq::Cron::Job.create(name: "RecurringPollWorker - each hourly", cron: '0 * * * *', klass: 'RecurringPollWorker')
    Sidekiq::Cron::Job.create(name: "Check subscribe of member - each day", cron: '5 17 * * *', klass: 'CheckSubscribeWorker')
  end

  desc "Create Signup Campaign as free 5 public poll"
  task :new_campaign_5_public_poll => :environment do
    Campaign.create!(name: "First signup free 5 public poll", used: 0, limit: 100000000, begin_sample: 1, end_sample: 1, expire: Time.now + 100.years,
      description: "Gift", how_to_redeem: "กดรับเอง", redeem_myself: true, reward_info: { "point" => 5, "first_signup" => true }, reward_expire: Time.now + 100.years, system_campaign: true,
      rewards_attributes: [{ title: "5 public poll", detail: "แจกฟรี 5 public poll free"}] )
  end

end
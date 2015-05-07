namespace :admin do
  desc "create admin"
  task create: :environment do
    Admin.create!(email: "admin@code-app.com", password: "mefuwfhfu", password_confirmation: "mefuwfhfu")
  end

  # create pollios account celebrity #

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
  # Member.where(cover: nil, cover_preset: "0").each do |m|
  #   m.update!(cover_preset: rand(1..28))
  # end

  desc "Update synce facebook"
  task :sync_facebook => :environment do
    Member.all.each do |member|
      if member.providers.where(name: 'facebook').present?
        member.update(sync_facebook: true)
      end
    end
  end


  # NotifyLog.all.each do |notify_log|
  #   poll_id = notify_log.custom_properties[:poll_id]
  #   if poll_id != nil
  #     find_poll = Poll.find_by(id: poll_id)

  #     unless find_poll.present?
  #       NotifyLog.where("custom_properties LIKE ?", "%poll_id: #{poll_id}%").update_all(poll_deleted: true)
  #     end
  #   end
  # end

  # Group.where(public_id: nil).each do |g|
  #   g.update!(public_id: "pollios" << g.id.to_s)
  # end

  # Group.where(public_id: "").each do |g|
  #   g.update!(public_id: "pollios" << g.id.to_s)
  # end

  desc "Update reward expire in reward"
  task :update_reward_expire => :environment do
    Reward.all.each do |reward|
      reward.update(reward_expire: reward.campaign.reward_expire) if reward.campaign.present?
    end
  end

  desc "Create sidekiq cron job"
  task :create_sidekiq_cron => :environment do
    Sidekiq::Cron::Job.create(name: "SavePollWorker - every at 18:00", cron: '0 18 * * * Asia/Bangkok', klass: 'SavePollWorker')
    Sidekiq::Cron::Job.create(name: "RecurringPollWorker - each hourly", cron: '0 * * * *', klass: 'RecurringPollWorker')
    Sidekiq::Cron::Job.create(name: "Check subscribe of member - each day at 00:00", cron: '0 0 * * * Asia/Bangkok', klass: 'CheckSubscribeWorker')
  end

  desc "Reset Popular tag worker"
  task :reset_tags_popular_cron => :environment do
    Sidekiq::Cron::Job.create(name: "Reset popular tags - each day", cron: "0 0 * * * Asia/Bangkok", klass: 'ResetPopularTagWorker')
  end

  desc "Check blacklist members"
  task :check_blacklist_members => :environment do
    Sidekiq::Cron::Job.create(name: "Check blacklist members - each day", cron: "0 0 * * * Asia/Bangkok", klass: 'CheckBlacklistMemberWorker')
  end

  desc "Create Signup Campaign as free 5 public poll"
  task :new_campaign_5_public_poll => :environment do
    Campaign.create!(name: "First signup free 5 public poll", used: 0, limit: 100000000, begin_sample: 1, end_sample: 1, expire: Time.now + 100.years,
      description: "Gift", how_to_redeem: "กดรับเอง", redeem_myself: true, reward_info: { "point" => 5, "first_signup" => true }, reward_expire: Time.now + 100.years, system_campaign: true,
      rewards_attributes: [{ title: "5 public poll", detail: "แจกฟรี 5 public poll free"}] )
  end


  desc "update member_id to group"
  task :update_member_to_group => :environment do
    Group.with_group_type(:company).each do |group|
      member_id = group.group_company.company.member.id
      group.update!(member_id: member_id)
    end

    Group.with_group_type(:normal).each do |group|
      member = group.group_members.order("group_members.id asc").first
      if member.present?
        group.update!(member_id: member.member_id)
      end
    end
  end

  desc "Reset Server"
  task :reset_server => :environment do
    AccessWeb.delete_all
    AccessWeb.connection.execute('ALTER SEQUENCE access_webs_id_seq RESTART WITH 1')

    ActivityFeed.delete_all
    ActivityFeed.connection.execute('ALTER SEQUENCE activity_feeds_id_seq RESTART WITH 1')

    ApiToken.delete_all
    ApiToken.connection.execute('ALTER SEQUENCE api_tokens_id_seq RESTART WITH 1')

    Apn::Device.delete_all
    Apn::Device.connection.execute('ALTER SEQUENCE apn_devices_id_seq RESTART WITH 1')

    Apn::Notification.delete_all
    Apn::Notification.connection.execute('ALTER SEQUENCE apn_notifications_id_seq RESTART WITH 1')

    Bookmark.delete_all
    Bookmark.connection.execute('ALTER SEQUENCE bookmarks_id_seq RESTART WITH 1')

    BranchPollSeries.delete_all
    BranchPollSeries.connection.execute('ALTER SEQUENCE branch_poll_series_id_seq RESTART WITH 1')

    BranchPoll.delete_all
    BranchPoll.connection.execute('ALTER SEQUENCE branch_polls_id_seq RESTART WITH 1')

    CampaignMember.delete_all
    CampaignMember.connection.execute('ALTER SEQUENCE campaign_members_id_seq RESTART WITH 1')

    Campaign.delete_all
    Campaign.connection.execute('ALTER SEQUENCE campaigns_id_seq RESTART WITH 1')

    Choice.delete_all
    Choice.connection.execute('ALTER SEQUENCE choices_id_seq RESTART WITH 1')

    CollectionPollBranch.delete_all
    CollectionPollBranch.connection.execute('ALTER SEQUENCE collection_poll_branches_id_seq RESTART WITH 1')

    
  end

end
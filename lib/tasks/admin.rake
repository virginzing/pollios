require 'rest_client'

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

  desc "Setup default to PolliosApp"
  task :setup_polliosapp => :environment do
    PolliosApp.create!(name: "Pollios", app_id: "com.pollios.polliosapp", platform: "ios")
    PolliosApp.create!(name: "Pollios Flickz", app_id: "com.pollios.polliosapp.flickz", platform: "ios")
    PolliosApp.create!(name: "Pollios Beta", app_id: "com.pollios.polliosappbeta", platform: "ios")
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

  desc "Set up a default of poll preset"
  task :set_up_default_poll_preset => :environment do
    poll_preset_names = %w(likedislike yesno rating)
    poll_preset_names.each_with_index do |name, index|
      PollPreset.create(preset_id: index+1, name: name, count: 0)
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
    Sidekiq::Cron::Job.create(name: "Check nearly expire subscription - each day at 00:00", cron: '0 0 * * * Asia/Bangkok', klass: 'CheckNearlyExpireSubscriptionWorker')
    Sidekiq::Cron::Job.create(name: "Close poll when poll expired - each day at 00:00", cron: '0 0 * * * Asia/Bangkok', klass: 'AutoPollExpireWorker')
    Sidekiq::Cron::Job.create(name: "Daily expire to questionnaires - each day at 00:00", cron: '0 0 * * * Asia/Bangkok', klass: 'DailyCheckExpireQuestionnairesWorker')
  end

  desc "Delete to notification logs every 3 days"
  task :cron_delete_notification_log => :environment do
    Sidekiq::Cron::Job.create(name: "AutoDeleteNotificationLogEvery3DaysWorker - every 3 days", cron: '0 0 */3 * * Asia/Bangkok', klass: 'AutoDeleteNotificationLogEvery3DaysWorker')
  end

  desc "Reset Popular tag worker"
  task :reset_tags_popular_cron => :environment do
    Sidekiq::Cron::Job.create(name: "Reset popular tag- each day", cron: "0 0 * * * Asia/Bangkok", klass: 'ResetPopularTagWorker')
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

  desc "Default member and company and campaign"
  task :default_member_company_campaign => :environment do

    host = Rails.env.production? ? "http://codeapp-user.herokuapp.com/codeapp/signup.json" : "http://codeapp-user-dev.herokuapp.com/codeapp/signup.json"

    params = {
      email: "polliosadmin@code-app.com",
      password: "9code7app9",
      password_confirmation: "9code7app9",
      fullname: "Pollios Admin"
    }

    RestClient.post host, params

    member = Member.create!(fullname: "Pollios Admin", email: "polliosadmin@code-app.com", description: "Pollios Admin Official", cover_preset: 1, first_signup: false, created_company: true, waiting: false, member_type: :company)

    company = Company.create!(name: "Pollios", member: member, using_service: ["Survey", "Feedback"], company_admin: true)

    company.feedback_recurrings.create!(period: '00:00')

    group = Group.create!(name: "Pollios", public: false, description: "Group Pollios Official", member: member, cover_preset: 1, system_group: true, group_type: :company)

    group.add_user_to_group(Member.where(id: member))

    GroupCompany.create!(group: group, company: company, main_group: true)

    Campaign.create!(name: "First signup free 5 public poll", used: 0, limit: 100000000, begin_sample: 1, end_sample: 1, expire: Time.now + 100.years, member: member,  company: company,
      description: "Gift", how_to_redeem: "กดรับเอง", redeem_myself: true, reward_info: { "point" => 5, "first_signup" => true }, reward_expire: Time.now + 100.years, system_campaign: true,
      rewards_attributes: [{ title: "5 public poll", detail: "แจกฟรี 5 public poll free", reward_expire: Time.now + 100.years, order_reward: 0 }] )
  end

  desc "Default Group Recommendation"
  task :task_name => [:dependent, :tasks] do

  end

  desc "Set default to The Notification of Member"
  task :set_default_notification => :environment do
    Member.all.each do |member|
      member.notification = Member::Notification::DEFAULT
      member.save!
    end
  end

  desc "Reset specific some table"
  task :reset_specific_table => :environment do
    AccessWeb.delete_all
    AccessWeb.connection.execute('ALTER SEQUENCE access_webs_id_seq RESTART WITH 1')

    Activity.delete_all

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

    Branch.delete_all
    Branch.connection.execute('ALTER SEQUENCE branches_id_seq RESTART WITH 1')

    BranchPollSeries.delete_all
    BranchPollSeries.connection.execute('ALTER SEQUENCE branch_poll_series_id_seq RESTART WITH 1')

    BranchPoll.delete_all
    BranchPoll.connection.execute('ALTER SEQUENCE branch_polls_id_seq RESTART WITH 1')

    CampaignMember.delete_all
    CampaignMember.connection.execute('ALTER SEQUENCE campaign_members_id_seq RESTART WITH 1')

    GiftLog.delete_all
    GiftLog.connection.execute('ALTER SEQUENCE gift_logs_id_seq RESTART WITH 1')

    Campaign.delete_all
    Campaign.connection.execute('ALTER SEQUENCE campaigns_id_seq RESTART WITH 1')

    Choice.delete_all
    Choice.connection.execute('ALTER SEQUENCE choices_id_seq RESTART WITH 1')

    CollectionPollBranch.delete_all
    CollectionPollBranch.connection.execute('ALTER SEQUENCE collection_poll_branches_id_seq RESTART WITH 1')

    CollectionPollSeries.delete_all
    CollectionPollSeries.connection.execute('ALTER SEQUENCE collection_poll_series_id_seq RESTART WITH 1')

    CollectionPollSeriesBranch.delete_all
    CollectionPollSeriesBranch.connection.execute('ALTER SEQUENCE collection_poll_series_branches_id_seq RESTART WITH 1')

    CollectionPoll.delete_all
    CollectionPoll.connection.execute('ALTER SEQUENCE collection_polls_id_seq RESTART WITH 1')

    Comment.delete_all
    Comment.connection.execute('ALTER SEQUENCE comments_id_seq RESTART WITH 1')

    Company.delete_all
    Company.connection.execute('ALTER SEQUENCE companies_id_seq RESTART WITH 1')

    CompanyMember.delete_all
    CompanyMember.connection.execute('ALTER SEQUENCE company_members_id_seq RESTART WITH 1')

    CoverPreset.delete_all

    DeletePoll.delete_all

    FeedbackRecurring.delete_all
    FeedbackRecurring.connection.execute('ALTER SEQUENCE feedback_recurrings_id_seq RESTART WITH 1')

    Friend.delete_all
    Friend.connection.execute('ALTER SEQUENCE friends_id_seq RESTART WITH 1')

    Group.delete_all
    Group.connection.execute('ALTER SEQUENCE groups_id_seq RESTART WITH 1')

    GroupCompany.delete_all
    GroupCompany.connection.execute('ALTER SEQUENCE group_companies_id_seq RESTART WITH 1')

    GroupMember.delete_all
    GroupMember.connection.execute('ALTER SEQUENCE group_members_id_seq RESTART WITH 1')

    GroupStats.delete_all

    GroupSurveyor.delete_all
    GroupSurveyor.connection.execute('ALTER SEQUENCE group_surveyors_id_seq RESTART WITH 1')

    HiddenPoll.delete_all
    HiddenPoll.connection.execute('ALTER SEQUENCE hidden_polls_id_seq RESTART WITH 1')

    HistoryPurchase.delete_all
    HistoryPurchase.connection.execute('ALTER SEQUENCE history_purchases_id_seq RESTART WITH 1')

    HistoryView.delete_all
    HistoryView.connection.execute('ALTER SEQUENCE history_views_id_seq RESTART WITH 1')

    HistoryViewQuestionnaire.delete_all
    HistoryViewQuestionnaire.connection.execute('ALTER SEQUENCE history_view_questionnaires_id_seq RESTART WITH 1')

    HistoryVote.delete_all
    HistoryVote.connection.execute('ALTER SEQUENCE history_votes_id_seq RESTART WITH 1')

    InviteCode.delete_all
    InviteCode.connection.execute('ALTER SEQUENCE invite_codes_id_seq RESTART WITH 1')

    Invite.delete_all
    Invite.connection.execute('ALTER SEQUENCE invites_id_seq RESTART WITH 1')

    MemberInviteCode.delete_all
    MemberInviteCode.connection.execute('ALTER SEQUENCE member_invite_codes_id_seq RESTART WITH 1')

    Member.delete_all
    Member.connection.execute('ALTER SEQUENCE members_id_seq RESTART WITH 1')

    Member.connection.execute("DELETE FROM members_roles")

    MemberUnRecomment.delete_all
    MemberUnRecomment.connection.execute('ALTER SEQUENCE member_un_recomments_id_seq RESTART WITH 1')

    MemberReportMember.delete_all
    MemberReportMember.connection.execute('ALTER SEQUENCE member_report_members_id_seq RESTART WITH 1')

    MemberReportComment.delete_all
    MemberReportComment.connection.execute('ALTER SEQUENCE member_report_comments_id_seq RESTART WITH 1')

    MemberReportPoll.delete_all
    MemberReportPoll.connection.execute('ALTER SEQUENCE member_report_polls_id_seq RESTART WITH 1')

    MemberPollFeed.delete_all

    Mention.delete_all
    Mention.connection.execute('ALTER SEQUENCE mentions_id_seq RESTART WITH 1')

    NotifyLog.delete_all
    NotifyLog.connection.execute('ALTER SEQUENCE notify_logs_id_seq RESTART WITH 1')

    PollAttachment.delete_all
    PollAttachment.connection.execute('ALTER SEQUENCE poll_attachments_id_seq RESTART WITH 1')

    PollGroup.delete_all
    PollGroup.connection.execute('ALTER SEQUENCE poll_groups_id_seq RESTART WITH 1')

    Poll.delete_all
    Poll.connection.execute('ALTER SEQUENCE polls_id_seq RESTART WITH 1')

    PollMember.delete_all
    PollMember.connection.execute('ALTER SEQUENCE poll_members_id_seq RESTART WITH 1')

    PollSeries.delete_all
    PollSeries.connection.execute('ALTER SEQUENCE poll_series_id_seq RESTART WITH 1')

    PollSeriesGroup.delete_all
    PollSeriesGroup.connection.execute('ALTER SEQUENCE poll_series_groups_id_seq RESTART WITH 1')

    PollSeriesTag.delete_all
    PollSeriesTag.connection.execute('ALTER SEQUENCE poll_series_tags_id_seq RESTART WITH 1')

    Provider.delete_all
    Provider.connection.execute('ALTER SEQUENCE providers_id_seq RESTART WITH 1')

    Recurring.delete_all
    Recurring.connection.execute('ALTER SEQUENCE recurrings_id_seq RESTART WITH 1')

    Redeemer.delete_all
    Redeemer.connection.execute('ALTER SEQUENCE redeemers_id_seq RESTART WITH 1')

    RequestCode.delete_all
    RequestCode.connection.execute('ALTER SEQUENCE request_codes_id_seq RESTART WITH 1')

    RequestGroup.delete_all
    RequestGroup.connection.execute('ALTER SEQUENCE request_groups_id_seq RESTART WITH 1')

    Reward.delete_all
    Reward.connection.execute('ALTER SEQUENCE rewards_id_seq RESTART WITH 1')

    Role.delete_all
    Role.connection.execute('ALTER SEQUENCE roles_id_seq RESTART WITH 1')

    SavePollLater.delete_all
    SavePollLater.connection.execute('ALTER SEQUENCE save_poll_laters_id_seq RESTART WITH 1')

    SharePoll.delete_all
    SharePoll.connection.execute('ALTER SEQUENCE share_polls_id_seq RESTART WITH 1')

    SpecialQrcode.delete_all
    SpecialQrcode.connection.execute('ALTER SEQUENCE special_qrcodes_id_seq RESTART WITH 1')

    Suggest.delete_all
    Suggest.connection.execute('ALTER SEQUENCE suggests_id_seq RESTART WITH 1')

    SuggestGroup.delete_all
    SuggestGroup.connection.execute('ALTER SEQUENCE suggest_groups_id_seq RESTART WITH 1')

    Tag.delete_all
    Tag.connection.execute('ALTER SEQUENCE tags_id_seq RESTART WITH 1')

    Tagging.delete_all
    Tagging.connection.execute('ALTER SEQUENCE taggings_id_seq RESTART WITH 1')

    Template.delete_all

    Trigger.delete_all
    Trigger.connection.execute('ALTER SEQUENCE triggers_id_seq RESTART WITH 1')

    TypeSearch.delete_all

    UnSeePoll.delete_all
    UnSeePoll.connection.execute('ALTER SEQUENCE un_see_polls_id_seq RESTART WITH 1')

    UserStats.delete_all

    VoteStats.delete_all

    Watched.delete_all
    Watched.connection.execute('ALTER SEQUENCE watcheds_id_seq RESTART WITH 1')

    PollCompany.delete_all
    PollCompany.connection.execute('ALTER SEQUENCE poll_companies_id_seq RESTART WITH 1')

    PollSeriesCompany.delete_all
    PollSeriesCompany.connection.execute('ALTER SEQUENCE poll_series_companies_id_seq RESTART WITH 1')

    LeaveGroupLog.delete_all
    LeaveGroupLog.connection.execute('ALTER SEQUENCE leave_group_logs_id_seq RESTART WITH 1')

    HistoryPromotePoll.delete_all
    HistoryPromotePoll.connection.execute('ALTER SEQUENCE history_promote_polls_id_seq RESTART WITH 1')

  end

  desc "Users in group that follow to owner group"
  task :follow_owner_group, [:group_id] => :environment do |t, args|
    begin
      p "find group with id #{args.group_id}"
      find_group = Group.cached_find(args.group_id.to_i)
      p "find group success"
      find_owner_group = find_group.member
      p "find owner group is #{find_owner_group.get_name}"
      p "#{find_owner_group.get_name} not Company Account" unless find_owner_group.company?
      p "All users in groups is following #{find_owner_group.get_name}. Process..."
      list_members = Group::ListMember.new(find_group).active.select{|m| m unless m.company? }
      list_members.each do |member|
        begin
          Friend.add_following(member, {member_id: member.id, friend_id: find_owner_group.id})
        rescue => e
          true
        end
      end
      p "done."
    rescue => e
      p e.message
    end
  end

end

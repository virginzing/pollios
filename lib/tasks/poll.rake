namespace :poll do
  desc "Choice Count"
  task choice_count: :environment do
    Poll.all.each do |poll|
      poll.update(choice_count: poll.choices.count)
    end
  end

  desc "Update History Vote"
  task :update_history_vote => :environment do
    HistoryVote.all.each do |hv|
      poll_series_id = 0
      if hv.poll.present?
        if hv.poll.series
          poll_series_id = hv.poll.poll_series_id
        end
        hv.update_attributes!(poll_series_id: poll_series_id)
      else
        hv.destroy
      end
    end
  end

  desc "update in_group_ids"

  task :update_in_group_ids => :environment do
    Poll.all.each do |poll|
      if poll.groups.present?
        group_ids = poll.groups.map(&:id)*","
      else
        group_ids = "0"
      end
      poll.update_attributes!(in_group_ids: group_ids)
    end
  end

  desc "update qrcode key"
  task :update_qrcode => :environment do
    Poll.all.each do |poll|
      poll.update!(qrcode_key: SecureRandom.hex)
    end
  end

  desc "clear all data"
  task :clear => :environment do
    Member.delete_all
    Poll.delete_all
    Tag.delete_all
    Tagging.delete_all

    PollMember.delete_all
    PollGroup.delete_all
    PollSeries.delete_all
    Choice.delete_all
    PollSeriesTag.delete_all
    Campaign.delete_all
    HistoryVoteGuest.delete_all
    HistoryViewGuest.delete_all
    CampaignMember.delete_all
    CampaignGuest.delete_all
    Group.delete_all
    Recurring.delete_all
    SharePoll.delete_all
    Provider.delete_all
    GroupMember.delete_all
    HiddenPoll.delete_all
    HistoryVote.delete_all
    HistoryView.delete_all
    Friend.delete_all

    InviteCode.delete_all
    MemberInviteCode.delete_all
    MemberReportMember.delete_all
    MemberReportPoll.delete_all
    NotifyLog.delete_all
    Watched.delete_all
    Apn::Device.delete_all
    Apn::Notification.delete_all

    Activity.delete_all
    Commment.delete_all
    Company.delete_all

    UserStats.delete_all
    VoteStats.delete_all
    GroupStats.delete_all
    Template.delete_all

  end

  desc "clear some data"
  task :clear_somedata => :environment do
    Poll.all.each do |poll|
      poll.destroy
    end
    Tag.delete_all
    PollSeries.delete_all
  end

  # desc "update member type to poll"

  # Poll.includes(:member).each do |p|
  #   p.update!(member_type: p.member.member_type_text)
  # end

  
  # desc "Update choice_text to history voted"
  # task :choice_text => :environment do
  #   HsitoryVote.all.each do |h|
  #     if choice.present?
  #       h.update!(choice_text: h.choice.answer)
  #     end
  #   end
  # end

end

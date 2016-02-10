module Member::Private::PollAction

  private
  
  def poll_inquiry_service
    @poll_inquiry_service ||= Member::PollInquiry.new(member, poll)
  end

  def create_poll_viewing_record
    return if HistoryView.exists?(member_id: member.id, poll_id: poll.id)
    
    create_history_view_for_member
    
    clear_history_viewed_cached_for_member
  end

  def create_history_view_for_member
    HistoryView.transaction do
      HistoryView.create! member_id: member.id, poll_id: poll.id
      create_company_group_action_tracking_record_for_action('view')

      poll.with_lock do
        poll.view_all += 1
        poll.save!
      end
    end
  end

  def create_company_group_action_tracking_record_for_action(action, new_poll = nil)
    poll = @poll || new_poll
    return unless poll.in_group

    group_ids = poll.in_group_ids.split(',').map(&:to_i)
    group_ids.each do |group_id|
      member.activity_feeds.create! action: action, trackable: poll, group_id: group_id
    end
  end

  def process_create
    new_poll = Poll.create!(member_id: member.id \
      , title: poll_params[:title] \
      , type_poll: poll_params[:type_poll] \
      , allow_comment: poll_params[:allow_comment] \
      , creator_must_vote: poll_params[:creator_must_vote] \
      , public: poll_public \
      , in_group_ids: in_group_ids \
      , thumbnail_type: poll_params[:thumbnail_type])

    poll_set(new_poll)
    own_poll_action(new_poll)
    decrease_point

    new_poll
  end

  def poll_public
    poll_params[:public] || false
  end

  def poll_set(new_poll)
    poll_choice(new_poll)
    poll_attachments(new_poll)
    poll_update(new_poll)
    poll_tag(new_poll)
    poll_member(new_poll)
    poll_group(new_poll)
    poll_company(new_poll)
  end

  def poll_choice(new_poll)
    poll_params[:choices].each do |choice|
      new_poll.choices.create!(answer: choice)
    end
  end

  def poll_attachments(new_poll)
    return unless poll_params[:original_images]

    convert_original_images.each_with_index do |url_attachment, index|
      new_poll.poll_attachments.create!(order_image: index + 1)
      new_poll.poll_attachments.find_by(order_image: index + 1).update_column(:image, url_attachment)
    end
  end

  def convert_original_images
    poll_params[:original_images].collect! do |image_url|
      ImageUrl.new(image_url).split_cloudinary_url
    end
  end

  def poll_update(new_poll)
    new_poll.update_column(:photo_poll, photo_poll)
    new_poll.update!(expire_date: expire_date \
      , poll_series_id: 0 \
      , choice_count: choice_count \
      , qrcode_key: qrcode_key \
      , member_type: member_type \
      , qr_only: false \
      , require_info: false \
      , in_group: poll_in_group)
  end

  def photo_poll
    return unless poll_params[:photo_poll]
    ImageUrl.new(poll_params[:photo_poll]).split_cloudinary_url
  end

  def expire_date
    Time.zone.now + 100.years
  end

  def choice_count
    poll_params[:choices].count
  end

  def in_group_ids
    return unless poll_in_group
    poll_params[:group_ids].join(',')
  end

  def poll_in_group
    poll_params[:group_ids].present?
  end

  def qrcode_key
    qrcode = SecureRandom.hex(6)
    return qrcode unless Poll.exists?(qrcode_key: qrcode)
    qrcode_key
  end

  def member_type
    member.member_type.capitalize
  end

  def poll_tag(new_poll)
    tags = []
    poll_params[:title].gsub(/\B#([[:word:]]+)/) do
      tags << Regexp.last_match[1]
    end
    
    return unless tags.count > 0
    tags.each do |tag|
      new_poll.tags << Tag.where(name: tag).first_or_create!
    end
  end

  def poll_member(new_poll)
    member.poll_members.create!(poll_id: new_poll.id, share_poll_of_id: 0, public: poll_public \
      , expire_date: expire_date, series: false, in_group: poll_in_group)
  end

  def poll_group(new_poll)
    return unless poll_in_group
    groups = Group.where(id: poll_params[:group_ids])
    groups.each do |group|
      group.poll_groups.create!(poll_id: new_poll.id, member_id: member.id)
    end
  end

  def poll_company(new_poll)
    return unless member.company?
    PollCompany.create!(poll_id: new_poll.id, company_id: member.company.id, post_from: 'mobile')
  end

  def own_poll_action(new_poll)
    process_watch(new_poll)
    create_company_group_action_tracking_record_for_action('create', new_poll)
  end

  def decrease_point
    return unless member.citizen? && poll_params[:public]
    member.with_lock do
      member.point -= 1
      member.save!
    end
  end

  def process_close
    poll.update!(close_status: true)
    poll
  end

  def process_vote
    increase_vote_count
    create_company_group_action_tracking_record_for_action('vote')
    create_history_vote
    delete_saved_poll
    trigger_vote

    claer_voted_all_cached_for_member
    clear_voting_poll_cached_for_member
    send_vote_notification

    predict_campaign

    poll
  end

  def choice
    Choice.cached_find(vote_params[:choice_id])
  end

  def increase_vote_count
    choice.with_lock do
      choice.vote += 1
      choice.save!  
    end

    poll.with_lock do
      poll.vote_all += 1
      poll.save!
    end
  end

  def create_history_vote
    HistoryVote.create!(member_id: member.id, poll_id: poll.id, choice_id: choice.id \
      , poll_series_id: poll_series_id, data_analysis: vote_params[:data_analysis], surveyor_id: vote_params[:surveyor_id] \
      , created_at: Time.zone.now + 0.5.seconds, show_result: show_result)
  end

  def poll_series_id
    poll.series ? poll.poll_series_id : 0
  end
  
  def show_result
    !vote_params[:anonymous]
  end

  def trigger_vote
    Trigger::Vote.new(member, poll, choice).trigger!
  end

  def predict_campaign
    return unless poll.get_campaign
    poll.find_campaign_for_predict?(member)
  end

  def process_bookmark
    Bookmark.create!(member_id: member.id, bookmarkable: poll)
    clear_bookmarked_cached_for_member
    poll
  end

  def process_unbookmark
    bookmarked_poll = Bookmark.find_by(member_id: member.id, bookmarkable_id: poll.id)
    return unless bookmarked_poll.present?
    bookmarked_poll.destroy

    clear_bookmarked_cached_for_member
    poll
  end

  def process_save
    SavePollLater.create!(member_id: member.id, savable: poll)

    clear_saved_cached_for_member
    poll
  end

  def process_watch(new_poll = nil)
    poll = @poll || new_poll
    watched_poll = member.watcheds.find_by(poll_id: poll.id)

    if watched_poll.present?
      watched_poll.update!(poll_notify: true, comment_notify: true)
    else
      member.watcheds.create!(poll: poll, poll_notify: true, comment_notify: true)
    end

    clear_watched_cached_for_member
    poll
  end

  def process_unwatch
    watched_poll = member.watcheds.find_by(poll_id: poll.id)
    return unless watched_poll.present?
    watched_poll.update!(poll_notify: false, comment_notify: false)

    clear_watched_cached_for_member
    poll
  end

  def process_not_interest
    NotInterestedPoll.create!(member_id: member.id, unseeable: poll)
    NotifyLog.deleted_with_poll_and_member(poll, member)

    sever_member_relation_to_poll

    poll
  end

  def delete_saved_poll
    saved_poll = SavePollLater.find_by(member_id: member.id, savable: poll)
    return unless saved_poll.present?
    saved_poll.destroy
    clear_saved_cached_for_member
  end

  def process_promote
    if member.citizen?
      member.with_lock do
        member.point -= 1
        member.save!
      end
    end

    HistoryPromotePoll.create!(member_id: member.id, poll: poll)
    poll.update!(public: true)
    poll.poll_member.find_by(member_id: member.id).update!(public: true)
    poll
  end

  def process_report
    MemberReportPoll.create!(member_id: member.id, poll_id: poll.id \
      , message: report_params[:message], message_preset: report_params[:message_preset])
    reporting

    NotifyLog.deleted_with_poll_and_member(poll, member)

    claer_voted_cached_for_member
    clear_reported_cached_for_member
    
    send_report_notification if poll.in_group

    poll
  end

  def reporting
    increase_report_count

    sever_member_relation_to_poll

    return unless poll.report_count >= 10
    poll.update!(status_poll: :black)
  end

  def increase_report_count
    poll.with_lock do
      poll.report_count += member.report_power
      poll.save!
    end
  end

  def process_delete
    sever_member_relation_to_poll
    create_company_group_action_tracking_record_for_action('delete')
    NotifyLog.check_update_poll_deleted(poll)
    poll.destroy

    return
  end

  def sever_member_relation_to_poll
    process_unbookmark
    delete_saved_poll
    process_unwatch
  end

  def process_comment
    comment = poll.comments.create!(member_id: member.id, message: comment_params[:message])
    increase_comment_count

    mentioning(comment, comment_params[:mention_ids])
    process_watch

    MemberActiveRecord.record_member_active(member)

    Poll::CommentList.new(poll, viewing_member: member)
  end

  def increase_comment_count
    poll.with_lock do
      poll.comment_count += 1
      poll.save!
    end
  end

  def mentioning(comment, mention_ids)
    return unless mention_ids.present?
    mentionable_ids = Poll::MemberList.new(poll, viewing_member: member).filler_mentionable(mention_ids)
    create_mentions(comment, member, mentionable_ids)
  end

  def create_mentions(comment, member, mentionable_ids)
    mentionable_list = Member.where(id: mentionable_ids)
    mentionable_list.each do |mentionable|
      comment.mentions.create!(mentioner_id: member.id, mentioner_name: member.fullname \
        , mentionable_id: mentionable.id, mentionable_name: mentionable.fullname)
    end
  end

  def process_report_comment
    MemberReportComment.create!(member_id: member.id, poll_id: poll.id, comment_id: comment_params[:comment_id] \
      , message: comment_params[:message], message_preset: comment_params[:message_preset])

    increase_report_comment_count
    clear_reported_comment_cached_for_member

    return
  end

  def increase_report_comment_count
    comment = Comment.cached_find(comment_params[:comment_id])
    comment.with_lock do
      comment.report_count += member.report_power
      comment.save!
    end
  end

  def process_delete_comment
    comment = poll.comments.cached_find(comment_params[:comment_id])
    NotifyLog.check_update_comment_deleted(comment)
    comment.destroy

    decrease_comment_count

    return
  end

  def decrease_comment_count
    poll.with_lock do
      poll.comment_count -= 1
      poll.save!
    end
  end

  def clear_history_viewed_cached_for_member
    FlushCached::Member.new(member).clear_list_history_viewed_polls
  end

  def claer_voted_all_cached_for_member
    FlushCached::Member.new(member).clear_list_voted_all_polls
  end

  def clear_bookmarked_cached_for_member
    FlushCached::Member.new(member).clear_list_bookmarked_polls
  end

  def clear_saved_cached_for_member
    FlushCached::Member.new(member).clear_list_saved_polls
  end

  def clear_watched_cached_for_member
    FlushCached::Member.new(member).clear_list_watched_polls
  end

  def clear_reported_cached_for_member
    FlushCached::Member.new(member).clear_list_report_polls
  end

  def clear_voting_poll_cached_for_member
    FlushCached::Member.new(member).clear_voting_detail_for_poll(poll.id)
  end

  def clear_reported_comment_cached_for_member
    FlushCached::Member.new(member).clear_list_report_comments
  end

  def send_report_notification
    ReportPollWorker.perform_async(member.id, poll.id) unless Rails.env.test?
  end

  def send_vote_notification
    return if poll.series || owner_poll
    sum_vote_notification
    Poll::VoteNotifyLog.new(member, poll, show_result).create!
  end

  def sum_vote_notification
    return unless poll.notify_state.idle?
    poll.update!(notify_state: 1)
    poll.update!(notify_state_at: Time.zone.now)
    SumVotePollWorker.perform_in(1.minutes, poll.id) unless Rails.env.test?
  end
end
module Member::Private::PollActionGuard

  # private

  def can_create?
    return [false, GuardMessage::Poll.less_choices] if less_choices
    return [false, GuardMessage::Poll.wrong_type_choices] if wrong_type_choices
    return [false, GuardMessage::Poll.public_quota_limit_exist] if poll_params[:public] && public_quota_limit_exist
    return [false, GuardMessage::Poll.out_of_group] if out_of_group

    [true, nil]
  end

  def can_close?
    return [false, GuardMessage::Poll.not_owner_poll] if not_owner_poll
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, GuardMessage::Poll.already_closed] if already_closed?

    [true, nil]
  end

  def can_vote?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    can_vote, message = poll_inquiry_service.can_vote?
    return [false, message] unless can_vote
    return [false, GuardMessage::Poll.already_voted] if already_vote
    return [false, GuardMessage::Poll.not_match_choice] if not_match_choice

    [true, nil]
  end

  def can_bookmark?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, GuardMessage::Poll.already_bookmarked] if already_bookmark

    [true, nil]
  end

  def can_unbookmark?
    return [false, GuardMessage::Poll.not_bookmarked] if not_bookmarked

    [true, nil]
  end

  def can_save?
    can_vote, message = can_vote?
    return [false, message] unless can_vote
    return [false, GuardMessage::Poll.already_saved] if already_save

    [true, nil]
  end

  def can_watch?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, GuardMessage::Poll.already_watch] if already_watch

    [true, nil]
  end

  def can_unwatch?
    return [false, GuardMessage::Poll.not_watching] if not_watching

    [true, nil]
  end

  def can_not_interest?
    can_vote, message = can_vote?
    return [false, message] unless can_vote

    [true, nil]
  end

  def can_promote?
    return [false, GuardMessage::Poll.not_owner_poll] if not_owner_poll
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, GuardMessage::Poll.already_closed] if already_closed?
    return [false, GuardMessage::Poll.already_public] if already_public
    return [false, GuardMessage::Poll.public_quota_limit_exist] if public_quota_limit_exist

    [true, nil]
  end

  def can_report?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, GuardMessage::Poll.report_own_poll] if owner_poll
    return [false, GuardMessage::Poll.already_report] if already_report

    [true, nil]
  end

  def can_delete?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, GuardMessage::Poll.not_owner_poll] if not_owner_poll

    [true, nil]
  end

  def can_comment?
    can_comment, message = poll_inquiry_service.can_comment?
    return [false, message] unless can_comment

    [true, nil]
  end

  def can_report_comment?
    can_comment, message = can_comment?
    return [false, message] unless can_comment
    return [false, GuardMessage::Poll.not_match_comment] if not_match_comment
    return [false, GuardMessage::Poll.report_own_comment] if owner_comment
    return [false, GuardMessage::Poll.already_report_comment] if already_report_comment

    [true, nil]
  end

  def can_delete_comment?
    can_comment, message = can_comment?
    return [false, message] unless can_comment
    return [false, GuardMessage::Poll.not_match_comment] if not_match_comment
    return [false, GuardMessage::Poll.not_owner_comment_and_poll] if not_owner_comment && not_owner_poll 

    [true, nil]
  end

  def less_choices
    poll_params[:choice_params].count < 2
  end

  def wrong_type_choices
    return false unless poll_params[:type_poll] == 'rating'
    return false unless poll_params[:choice_params] != %w(1 2 3 4 5)
    true
  end

  def public_quota_limit_exist
    member.point == 0 && member.citizen?
  end

  def out_of_group
    return false unless poll_params[:group_ids].present?
    return false unless poll_params[:group_ids] - Member::GroupList.new(member).groups_ids != []
    true
  end

  def owner_poll
    poll.member_id == member.id
  end

  def not_owner_poll
    !owner_poll
  end

  def already_closed?
    poll_inquiry_service.closed?
  end

  def not_match_choice
    return false unless vote_params.present?
    !poll.choices.map(&:id).include?(vote_params[:choice_id])
  end

  def already_vote
    poll_inquiry_service.voted?
  end

  def not_voted
    !already_vote
  end

  def already_bookmark
    poll_inquiry_service.bookmarked?
  end

  def not_bookmarked
    !already_bookmark
  end

  def already_save
    poll_inquiry_service.saved_for_later?
  end

  def already_watch
    poll_inquiry_service.watching?
  end

  def not_watching
    !already_watch
  end

  def already_not_interested
    poll_inquiry_service.not_interested?
  end

  def already_public
    poll.public
  end

  def already_report
    poll_inquiry_service.reported?
  end

  def not_match_comment
    !Poll::CommentList.new(poll, viewing_member: member).comments.map(&:id).include?(comment_params[:comment_id])
  end

  def owner_comment
    comment = Comment.cached_find(comment_params[:comment_id])
    comment.member_id == member.id
  end

  def not_owner_comment
    !owner_comment
  end

  def already_report_comment
    member.member_report_comments.exists?(comment_id: comment_params[:comment_id])
  end

end
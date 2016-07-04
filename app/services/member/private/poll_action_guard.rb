module Member::Private::PollActionGuard

  # private

  def can_create?
    return [false, less_choices_message] if less_choices
    return [false, wrong_type_choices_message] if wrong_type_choices
    return [false, public_quota_limit_exist_message] if poll_params[:public] && public_quota_limit_exist
    return [false, out_of_group_message] if out_of_group 

    [true, nil]
  end

  def can_close?
    return [false, not_owner_poll_message] if not_owner_poll
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, already_close_message] if already_close

    [true, nil]
  end

  def can_vote?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    can_vote, message = poll_inquiry_service.can_vote?
    return [false, message] unless can_vote
    return [false, already_vote_message] if already_vote
    return [false, not_match_choice_message] if not_match_choice

    [true, nil]
  end

  def can_bookmark?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, already_bookmark_message] if already_bookmark

    [true, nil]
  end

  def can_unbookmark?
    return [false, not_bookmarked_message] if not_bookmarked

    [true, nil]
  end

  def can_save?
    can_vote, message = can_vote?
    return [false, message] unless can_vote
    return [false, already_save_message] if already_save

    [true, nil]
  end

  def can_watch?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, already_watch_message] if already_watch

    [true, nil]
  end

  def can_unwatch?
    return [false, not_watching_message] if not_watching

    [true, nil]
  end

  def can_not_interest?
    can_vote, message = can_vote?
    return [false, message] unless can_vote

    [true, nil]
  end

  def can_promote?
    return [false, not_owner_poll_message] if not_owner_poll
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, already_close_message] if already_close
    return [false, already_public_message] if already_public
    return [false, public_quota_limit_exist_message] if public_quota_limit_exist

    [true, nil]
  end

  def can_report?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, report_own_poll_message] if owner_poll
    return [false, already_report_message] if already_report

    [true, nil]
  end

  def can_delete?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, not_owner_poll_message] if not_owner_poll

    [true, nil]
  end

  def can_comment?
    return [false, not_voted_and_poll_not_closed_message] if not_voted_and_poll_not_closed
    return [false, not_allow_comment_message] if not_allow_comment

    [true, nil]
  end

  def can_report_comment?
    can_comment, message = can_comment?
    return [false, message] unless can_comment
    return [false, not_match_comment_message] if not_match_comment
    return [false, report_own_comment_message] if owner_comment
    return [false, already_report_comment_message] if already_report_comment
      
    [true, nil]
  end

  def can_delete_comment?
    can_comment, message = can_comment?
    return [false, message] unless can_comment
    return [false, not_match_comment_message] if not_match_comment
    return [false, not_owner_comment_and_poll_message] if not_owner_comment && not_owner_poll 

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

  def already_close
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

  def not_voted_and_poll_not_closed
    not_voted && !poll.close_status
  end

  def not_allow_comment
    !poll.allow_comment
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
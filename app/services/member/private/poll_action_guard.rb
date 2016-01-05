module Member::Private::PollActionGuard

  # private

  def can_create?
    return [false, 'Poll must be have 2 choices at least.'] if less_choices
    return [false, 'Wrong type of choices.'] if wrong_type_choices
    return [false, "You don't have any public poll quota."] if poll_params[:public] && public_quota_limit_exist
    return [false, "You aren't member in group."] if out_of_group 

    [true, nil]
  end

  def can_close?
    return [false, "You aren't owner of this poll."] if not_owner_poll
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, 'This poll is already closed for voting.'] if already_close

    [true, nil]
  end

  def can_vote?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    can_vote, message = poll_inquiry_service.can_vote?
    return [false, message] unless can_vote
    return [false, 'You are already voted this poll.'] if already_vote

    [true, nil]
  end

  def can_bookmark?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, 'You are already bookmarked this poll.'] if already_bookmark

    [true, nil]
  end

  def can_unbookmark?
    return [false, "You aren't bookmarking this poll."] if not_bookmarked

    [true, nil]
  end

  def can_save?
    can_vote, message = can_vote?
    return [false, message] unless can_vote
    return [false, 'You are already saved this poll for vote later.'] if already_save

    [true, nil]
  end

  def can_watch?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, 'You are already watching this poll.'] if already_watch

    [true, nil]
  end

  def can_unwatch?
    return [false, "You aren't watching this poll."] if not_watching

    [true, nil]
  end

  def can_not_interest?
    can_vote, message = can_vote?
    return [false, message] unless can_vote
    return [false, 'You are already not interested this poll.'] if already_not_interested

    [true, nil]
  end

  def can_promote?
    return [false, "You aren't owner of this poll."] if not_owner_poll
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, 'This poll is already closed for voting.'] if already_close
    return [false, 'This poll is already public.'] if already_public
    return [false, "You don't have any public poll quota."] if public_quota_limit_exist

    [true, nil]
  end

  def can_report?
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, "You can't report your poll."] if owner_poll
    return [false, 'You are already reported this poll.'] if already_report

    [true, nil]
  end

  def can_comment?
    return [false, "You aren't vote this poll."] if not_voted

    [true, nil]
  end

  def less_choices
    poll_params[:choices].count < 2
  end

  def wrong_type_choices
    return false unless poll_params[:type_poll] == 'rating'
    return false unless poll_params[:choices] != %w(1 2 3 4 5)
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

end
# These methods are examples. Please kindly place new error message below these comments

# module GuardMessage

#   module Address 
#     class << self

#       def not_exist
#         'คุณไม่มีที่อยู่นี้'
#       end

#       def name_already_exists(name)
#         "คุณมีที่อยู่ชื่อ #{name} แล้ว\t\n"
#       end

#     end
#   end

#   module Invoice
#     class << self

#       def not_exist
#         'คุณไม่มียอดค้างชำระสินค้านี้อยู่'
#       end

#     end
#   end
#   .
#   .
#   .
# end

module GuardMessage
  ####### Member Action Message ##########

  def already_friend_message(a_member)
    "You and #{a_member.get_name} are already friends."
  end

  def not_friend_message(a_member)
    "You are not friends with #{a_member.get_name}."
  end

  def already_sent_request_message(a_member)
    "You already sent friend request to #{a_member.get_name}."
  end

  def add_self_as_a_friend_message
    "You can't add yourself as a friend."
  end

  def unfriend_self_message
    "You can't unfriend yourself."
  end

  def follow_self_message
    "You can't follow yourself."
  end

  def already_followed_message
    "You already followed this account."
  end

  def not_following_message
    "You are not following this account."
  end

  def unfollow_self_message
    "You can't unfollow yourself."
  end

  def block_self_message
    "You can't block yourself."
  end

  def already_blocked_message(a_member)
    "You already blocked #{a_member.get_name}."
  end

  def not_blocking_message(a_member)
    "You are not blocking #{a_member.get_name}."
  end

  def blocked_message(a_member)
    "#{a_member.get_name} blocks you."
  end

  def unblock_self_message
    "You can't unblock yourself."
  end

  def report_self_message
    "You can't report yourself."
  end

  def not_official_account_message
    "This member is not official account."
  end

  def friends_limit_exceed_message(a_member)
    "#{a_member.get_name} has over #{a_member.friend_limit} friends."
  end

  def accept_incoming_block_message
    "You can't accept this request at this moment."
  end

  def not_exist_incoming_request_message(a_member)
    "You don't have friend request from #{a_member.get_name}"
  end

  def not_exist_outgoing_request_message
    "This request is not existing."
  end

  #-----------------------------------------------------------

  def member_already_in_group(member_name, group_name)
    "#{member_name} is already in #{group_name}."
  end

  def member_is_not_in_group(member_name, group_name)
    "#{member_name} is not a member in #{group_name}."
  end

  def no_join_request_from_member(member_name, group_name)
    "#{member_name} haven't sent any join request to #{group_name}."
  end

  def cant_remove_yourself
    'You cannot remove yourself.'
  end

  def member_is_group_creator(member_name)
    "#{member_name} is a group creator."
  end

  def member_already_admin(member_name)
    "#{member_name} is already an admin."
  end

  def member_is_not_admin(member_name)
    "#{member_name} is not an admin."
  end

  ####### Poll Action Message ##########
  def less_choices_message
    'Poll must be have 2 choices at least.'
  end

  def wrong_type_choices_message
    'Wrong type of choices.'
  end

  def public_quota_limit_exist_message
    "You don't have any public poll quota."
  end

  def not_owner_poll_message
    "You aren't owner of this poll."
  end

  def already_closed_message
    'This poll is already closed for voting.'
  end

  def already_voted_message
    'You are already voted this poll.'
  end

  def not_match_choice_message
    "This poll haven't your selected choice."
  end

  def already_bookmark_message
    'You are already bookmarked this poll.'
  end

  def not_bookmarked_message
    "You aren't bookmarking this poll."
  end

  def already_saved_message
    'You are already saved this poll for vote later.'
  end

  def already_public_message
    'This poll is already public.'
  end

  def already_watch_message
    'You are already watching this poll.'
  end

  def not_watching_message
    "You aren't watching this poll."
  end

  def report_own_poll_message
    "You can't report your poll."
  end

  def already_report_message
    'You are already reported this poll.'
  end

  def not_voted_and_poll_not_closed_message
    "You aren't vote this poll."
  end

  def not_allow_comment_message
    "This poll isn't allow comment."
  end

  def report_own_comment_message
    "You can't report your comment."
  end

  def already_report_comment_message
    'You are already reported this comment.'
  end 

  def not_match_comment_message
    "This comment don't exists in poll."
  end

  def not_owner_comment_and_poll_message
    "You aren't owner this comment or this poll."
  end

  def only_for_frineds_or_following_message
    'This poll is allow vote for friends or following.'
  end

  def already_not_interest_message
    'You are already not interested this poll.'
  end

  def not_allow_your_own_vote_message
    "This poll isn't allow your own vote."
  end

  def you_are_already_block_message(fullname)
    "You are already blocked #{fullname}."
  end

  def allow_vote_for_group_member_message
    "This poll is allow vote for group's members."
  end

  def poll_incoming_block_message
    "You can't see this poll at this moment."
  end

  def draft_poll_message
    "You can't see draft poll."
  end
end

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
  module Member
    class << self
      def already_friend(a_member)
        "You and #{a_member.get_name} are already friends."
      end

      def not_friend(a_member)
        "You are not friends with #{a_member.get_name}."
      end

      def already_sent_request(a_member)
        "You already sent friend request to #{a_member.get_name}."
      end

      def add_self_as_a_friend
        "You can't add yourself as a friend."
      end

      def unfriend_self
        "You can't unfriend yourself."
      end

      def follow_self
        "You can't follow yourself."
      end

      def already_followed
        'You already followed this account.'
      end

      def not_following
        'You are not following this account.'
      end

      def unfollow_self
        "You can't unfollow yourself."
      end

      def block_self
        "You can't block yourself."
      end

      def already_blocked(a_member)
        "You already blocked #{a_member.get_name}."
      end

      def not_blocking(a_member)
        "You are not blocking #{a_member.get_name}."
      end

      def blocked_by(a_member)
        "You are blocked by #{a_member.get_name}."
      end

      def unblock_self
        "You can't unblock yourself."
      end

      def report_self
        "You can't report yourself."
      end

      def not_official_account
        'This member is not official account.'
      end

      def friends_limit_exceed(a_member)
        "#{a_member.get_name} has over #{a_member.friend_limit} friends."
      end

      def member_friends_limit_exceed(member)
        "You has over #{member.friend_limit} friends."
      end

      def accept_incoming_block
        "You can't accept this request at this moment."
      end

      def not_exist_incoming_request(a_member)
        "You don't have friend request from #{a_member.get_name}"
      end

      def not_exist_outgoing_request
        'This request is not existing.'
      end
    end
  end

  module Poll
    class << self
      def less_choices
        'Poll must be have 2 choices at least.'
      end

      def wrong_type_choices
        'Wrong type of choices.'
      end

      def public_quota_limit_exist
        "You don't have any public poll quota."
      end

      def out_of_group
        "You aren't member in group."
      end

      def not_owner_poll
        "You aren't owner of this poll."
      end

      def already_closed
        'This poll is already closed.'
      end

      def already_voted
        'You are already voted this poll.'
      end

      def not_match_choice
        "This poll haven't your selected choice."
      end

      def already_bookmarked
        'You are already bookmarked this poll.'
      end

      def not_bookmarked
        "You aren't bookmarking this poll."
      end

      def already_saved
        'You are already saved this poll for vote later.'
      end

      def already_public
        'This poll is already public.'
      end

      def already_watch
        'You are already watching this poll.'
      end

      def not_watching
        "You aren't watching this poll."
      end

      def report_own_poll
        "You can't report your poll."
      end

      def already_report
        'You are already reported this poll.'
      end

      def not_voted_and_poll_not_closed
        "You aren't vote this poll."
      end

      def not_allow_comment
        "This poll isn't allow comment."
      end

      def report_own_comment
        "You can't report your comment."
      end

      def already_report_comment
        'You are already reported this comment.'
      end

      def not_match_comment
        "This comment don't exists in poll."
      end

      def not_owner_comment_and_poll
        "You aren't owner this comment or this poll."
      end

      def only_for_frineds_or_following
        'This poll is allow vote for friends or following.'
      end

      def already_not_interest
        'You are already not interested this poll.'
      end

      def not_allow_your_own_vote
        "This poll isn't allow your own vote."
      end

      def you_are_already_block
        'You are already blocked.'
      end

      def allow_vote_for_group_member
        "This poll is allow vote for group's members."
      end

      def poll_incoming_block
        "You can't see this poll at this moment."
      end

      def draft_poll
        "You can't see draft poll."
      end

      def already_expired
        'This poll was already expired.'
      end
    end
  end

  module GroupAdminAction
    class << self
      def member_already_in_group(member, group)
        "#{member.get_name} is already in #{group.name}."
      end

      def member_is_not_in_group(member, group)
        "#{member.get_name} is not a member in #{group.name}."
      end

      def no_join_request_from_member(member, group)
        "#{member.get_name} haven't sent any join request to #{group.name}."
      end

      def cant_remove_yourself
        'You cannot remove yourself.'
      end

      def member_is_group_creator(member)
        "#{member.get_name} is a group creator."
      end

      def member_already_admin(member)
        "#{member.get_name} is already an admin."
      end

      def member_is_not_admin(member)
        "#{member.get_name} is not an admin."
      end
    end
  end
end

class ApnPoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll)
    @member = member
    @poll = poll
    @init_member_list_friend = Member::MemberList.new(@member)
  end

  def member
    @member
  end

  def recipient_ids
    if member.citizen?
      member_ids = apn_friend_ids
    else
      member_ids = (apn_friend_ids | follower_ids)
    end

    member_ids - @init_member_list_friend.blocked_by_someone
  end

  def receive_notification
    if member.citizen?
      member_ids = friend_open_notification
    else
      member_ids = (friend_open_notification | follower_open_notification)
    end

    member_ids - @init_member_list_friend.blocked_by_someone
  end

  def member_name
    member.fullname
  end
  
  def custom_message
    message = "#{member_name} added a new poll: \"#{@poll.title}\""
    truncate_message(message)
  end

  private

  def following_ids
    to_map_member_ids(@init_member_list_friend.following)
  end

  def follower_ids
    to_map_member_ids(@init_member_list_friend.follower)
  end

  def apn_friend_ids
    to_map_member_ids(@init_member_list_friend.active)
  end

  def friend_open_notification
    getting_notification(@init_member_list_friend.active_with_no_cache, "friend")
  end

  def follower_open_notification
    getting_notification(@init_member_list_friend.follower_with_no_cache, "friend")
  end
end


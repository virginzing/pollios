class Apn::FeedbackPublic
  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll_series)
    @member = member
    @poll_series = poll_series
    @init_member_list_friend = Member::ListFriend.new(@member)
  end

  def recipient_ids
    member_ids = (apn_friend_ids | follower_ids)
    (member_ids | member_open_notification_public) - @init_member_list_friend.blocked_by_someone
  end

  def member_name
    @member.fullname
  end

  def custom_message
    message = "#{member_name} added a new feedback: \"#{@poll_series.description}\""
    truncate_message(message)
  end

  private

  def following_ids
    to_map_member_ids(@init_member_list_friend.following_with_no_cache)
  end

  def follower_ids
    to_map_member_ids(@init_member_list_friend.follower_with_no_cache)
  end

  def apn_friend_ids
    to_map_member_ids(@init_member_list_friend.active_with_no_cache)
  end

  def member_open_notification_public
    to_map_member_ids(Member.with_notification_public) - [@member.id]
  end

end

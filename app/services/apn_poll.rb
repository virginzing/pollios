class ApnPoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll)
    @member = member
    @member_id = member.id
    @poll = poll
    @init_member_list_friend = Member::ListFriend.new(@member)
  end

  def member
    @member
  end

  def recipient_ids
    if member.citizen?
      apn_friend_ids
    else
      apn_friend_ids | follower_ids
    end
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
    received_notify_of_member_ids(@init_member_list_friend.following)
  end

  def follower_ids
    received_notify_of_member_ids(@init_member_list_friend.follower)
  end

  def apn_friend_ids
    received_notify_of_member_ids(@init_member_list_friend.active)
  end

end


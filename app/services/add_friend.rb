class AddFriend
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member_id, friend_id, options = {})
    @member_id = member_id
    @friend_id = friend_id
    @options = options
  end

  def recipient_id
    if friend
      friend.apn_add_friend ? friend.id : nil
    end
  end

  def member_name
    # member.sentai_name.split(%r{\s}).first
    member.sentai_name
  end

  def friend_name
    friend.sentai_name
  end

  def custom_message
    if @options[:accept_friend]
      message = member_name + " is now friends with you"
    else
      message = member_name + " request friend with you" 
    end
    truncate_message(message)
  end

  private

  def member
    Member.find(@member_id)
  end

  def friend
    Member.find(@friend_id)
  end
  
end
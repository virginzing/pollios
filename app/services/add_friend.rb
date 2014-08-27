class AddFriend
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, friend, options = {})
    @member = member
    @friend = friend
    @options = options
  end

  def recipient_id
    if @friend
      @friend.apn_add_friend ? @friend.id : nil
    end
  end

  def member_name
    # member.fullname.split(%r{\s}).first
    @member.fullname
  end

  def friend_name
    @friend.fullname
  end

  def custom_message
    if @options["accept_friend"]
      message = member_name + " is now friends with you"
    else
      message = member_name + " request friend with you" 
    end
    truncate_message(message)
  end
  
end
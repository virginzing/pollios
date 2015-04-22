class Apn::ApproveRequestGroup

  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, friend, group)
    @member = member
    @friend = friend
    @group = group
  end


  def recipient_ids
    @friend.id
  end

  def member_name
    @member.get_name
  end

  def group_name
    @group.name
  end

  # allow 170 byte for custom message
  def custom_message
    message = "#{member_name} approved your request to join #{group_name}"
    truncate_message(message)
  end
  
end
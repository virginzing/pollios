class AskJoinGroup
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, group)
    @member = member
    @group = group
  end

  def recipient_ids
    group_member_ids
  end

  def member_name
    @member.fullname
  end

  def group_name
    @group.name
  end

  def custom_message
    message = "#{member_name} joined #{group_name} group"
    truncate_message(message)
  end 

  private

  def group_member_ids
    received_notify_of_member_ids(@group.get_member_active) - [@member.id]
  end
  
end

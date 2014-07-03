class GroupNotification
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member_id, group, poll)
    @member_id = member_id
    @group = group
    @group_id = group.id
    @poll = poll
  end

  def group_member_ids
    @group.get_member_open_notification.collect(&:id).flatten - [@member_id]
  end

  def recipient_ids
    group.present? ? group_member_ids : []
  end

  def member_name
    member.fullname
  end

  def group_name
    # truncate(group.name, length: 10)
    @group.name
  end

  def custom_message
    message = "#{member_name} asked in #{group_name}: \"#{@poll.title}\""
    truncate_message(message)
  end

  private

  def member
    Member.find(@member_id)
  end
  
  
end
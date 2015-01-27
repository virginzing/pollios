class ApnPollToGroup
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, group, poll)
    @member = member
    @group = group
    @poll = poll
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
    message = "#{member_name} asked in #{group_name}: \"#{@poll.title}\""
    truncate_message(message)
  end 

  private

  def group_member_ids
    # @group.get_member_open_notification.collect(&:id).flatten - [@member.id]
    received_notify_of_member_ids(@group.get_member_active) - [@member.id]
  end

end

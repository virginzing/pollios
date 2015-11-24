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

  def receive_notification
    group_member_ids_open_notification
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
    to_map_member_ids(Group::MemberList.new(@group).active) - [@member.id]
  end

  def group_member_ids_open_notification
    getting_notification(Group::MemberList.new(@group).active_with_no_cache, "group") - [@member.id]
  end

end

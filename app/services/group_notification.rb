class GroupNotification
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member_id, group_id, poll)
    @member_id = member_id
    @group_id = group_id
    @poll = poll
  end

  def group_member_ids
    group.get_member_open_notification.collect(&:id).flatten
  end

  def recipient_ids
    group.present? ? group_member_ids : []
  end

  def member_name
    member.fullname.split(%r{\s}).first
  end

  def group_name
    truncate(group.name, length: 10)
  end

  def custom_message
    message = member_name + " asked " + @poll.title + " in " + group_name
    truncate_message(message)
  end

  private

  def member
    Member.find(@member_id)
  end

  def group
    Group.find_by(id: @group_id)
  end
  
  
end
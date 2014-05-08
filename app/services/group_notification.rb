class GroupNotification
  include ActionView::Helpers::TextHelper

  def initialize(member_id, group_id, poll_title)
    @member_id = member_id
    @group_id = group_id
    @poll_title = poll_title
  end

  def group_member_ids
    group.get_member_open_notification.collect(&:id).flatten
  end

  def recipient_ids
    group.present? ? group_member_ids : []
  end

  def member_name
    member.sentai_name.split(%r{\s}).first
  end

  def custom_poll_title
    truncate(@poll_title, length: 150)
  end

  def group_name
    truncate(group.name, length: 10)
  end

  def custom_message
    member_name + " asked " + custom_poll_title + " in " + group_name
  end

  private

  def member
    Member.find(@member_id)
  end

  def group
    Group.find_by(id: @group_id)
  end
  
  
end
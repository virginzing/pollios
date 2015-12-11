class AskJoinGroup
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, group)
    @member = member
    @group = group
  end

  def recipient_ids
    group_member_ids_open_notification
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

  def member_as_admin_ids
    Group::MemberList.new(@group).admins.map(&:id)
  end

  def group_member_ids
    member_as_admin_ids - [@member.id]
  end

  def group_member_ids_open_notification
    getting_notification(Group::MemberList.new(@group).active_with_no_cache, "join_group") - [@member.id]
  end

end

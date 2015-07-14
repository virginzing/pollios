class Apn::RequestGroup
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, group, options = nil)
    @member = member
    @group = group
    @options = options
  end

  def recipient_ids
    @group.present? ? admin_of_group_ids : []
  end

  def receive_notification
    member_open_notification
  end

  def member_name
    @member.fullname
  end

  def group_name
    @group.name
  end

  def custom_message
    message = "#{member_name} request to join #{group_name} group"

    truncate_message(message)
  end

  private

  def admin_of_group_ids
    @group.get_admin_group.pluck(:id).uniq
  end

  def member_open_notification
    list_members = Member.where(id: admin_of_group_ids)
    getting_notification(list_members, "request")
  end

end


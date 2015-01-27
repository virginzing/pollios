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

  def member_name
    @member.fullname
  end

  def group_name
    @group.name
  end

  def custom_message
    message = "#{member_name} request to join in #{group_name}"

    truncate_message(message)
  end 

  private

  def admin_of_group_ids
    @group.get_admin_group.where("members.receive_notify = 't'").pluck(:id).uniq
  end
  
end


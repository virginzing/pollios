module Notification::NewHelper
  include Notification::LogHelper
  include Notification::PushHelper

  attr_reader :alert_type, :log

  def create(member_list, data, message = nil, sender = nil)
    recipient_list = recipient_list(member_list, sender)

    create_push(recipient_list, data, message)

    create_log(recipient_list, data, message, sender) if log
  end

  private

  def create_log(recipient_list, data, message, sender = nil)
    create_update_log(recipient_list, data, message, sender)
    create_request_log(recipient_list, data) if request_notification?
  end

  def create_push(recipient_list, data, message = nil)
    device_list = device_list(recipient_list)

    device_list.each do |device|
      Rpush::Apns::Notification.create!(push_data(device, data, message))
    end
  end

  def recipient_list(member_list, sender)
    return member_list unless sender.present?

    member_list - [sender] - members_blocked_by(sender) - members_blocked(sender)
  end

  def members_blocked_by(sender)
    member_list_service(sender).blocks
  end

  def members_blocked(sender)
    member_blocked_sender_ids = member_list_service(sender).blocked_by_someone

    Member.find(member_blocked_sender_ids)
  end

  def member_list_service(sender)
    @member_list_service ||= Member::MemberList.new(sender, viewing_member: sender)
  end

end

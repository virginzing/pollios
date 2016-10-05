module Notification::NewHelper
  include Notification::LogHelper
  include Notification::PushHelper

  def create_only_log(member_list, type, data, message, sender = nil)
    recipient_list = recipient_list(member_list, sender)

    create_log(recipient_list, type, data, message, sender)
  end

  def create_only_push(member_list, type, data, message = nil, sender = nil)
    recipient_list = recipient_list(member_list, sender)

    create_push(recipient_list, type, data, message)
  end

  def create_log_and_push(member_list, type, data, message, sender = nil)
    recipient_list = recipient_list(member_list, sender)

    create_log(recipient_list, type, data, message, sender)
    create_push(recipient_list, type, data, message)
  end

  private

  def create_log(recipient_list, type, data, message, sender = nil)
    create_update_log(recipient_list, data, message, sender)
    create_request_log(recipient_list, data) if request_notification?(type)
  end

  def create_push(recipient_list, type, data, message = nil)
    device_list = device_list(recipient_list)

    device_list.each do |device|
      Rpush::Apns::Notification.create!(push_data(device, type, data, message))
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

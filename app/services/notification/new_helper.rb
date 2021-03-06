module Notification::NewHelper
  include Notification::LogHelper
  include Notification::PushHelper

  def create(member_list, message = nil, sender = nil)
    recipient_list = recipient_list(member_list, sender)

    create_push(recipient_list, message)

    create_log(recipient_list, message, sender) if log?
  end

  private

  def alert_type
    fail NotImplementedError
  end

  def log?
    fail NotImplementedError
  end

  def data
    fail NotImplementedError
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

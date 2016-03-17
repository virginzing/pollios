class Notification::Member::FriendsRequest
  include Notification::Helper
  include SymbolHash

  attr_reader :member, :a_member, :action

  def initialize(member, a_member, options = {})
    @member = member
    @a_member = a_member
    @action = options[:action]

    create_notification(member, recipients, 'request', message, data)
  end

  def recipients
    [a_member]
  end

  def notification_count
    a_member.increment!(:notification_count)
    a_member.notification_count
  end  

  def request_count
    a_member.increment!(:request_count)
    a_member.request_count
  end

  def message
    return member.fullname + ' had accepted your friend request' if action == 'accept_friend'
    member.fullname + ' request friend with you'
  end

  def data
    {
      type: TYPE[:friend],
      member_id: member.id,
      notify: notification_count,
      action: action,
      friend_id: a_member.id,
      worker: WORKER[:add_friend]
    }
  end

end
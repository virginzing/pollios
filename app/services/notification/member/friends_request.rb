class Notification::Member::FriendsRequest
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :a_member, :action

  def initialize(sender, a_member, options = {})
    @sender = sender
    @a_member = a_member
    @action = options['action']

    create(member_list, type, message, data)
  end

  def type
    'request'
  end

  def member_list
    [a_member]
  end

  def message
    return sender.fullname + ' accepted your friend request' if action == ACTION[:become_friend]
    sender.fullname + ' request friend with you'
  end

  def data
    @data ||= {
      type: TYPE[:friend],
      member_id: sender.id,
      action: action,
      friend_id: a_member.id,
      worker: WORKER[:friends_request]
    }
  end

end
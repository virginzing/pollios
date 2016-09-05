class Notification::Member::FriendsRequest
  include Notification::Helper
  include SymbolHash

  attr_reader :member, :a_member, :action

  def initialize(member, a_member, options = {})
    @member = member
    @a_member = a_member
    @action = options['action']

    create(recipient_list, type, message, data)
  end

  def type
    'request'
  end

  def recipient_list
    [a_member]
  end

  def message
    return member.fullname + ' had accepted your friend request' if action == ACTION[:become_friend]
    member.fullname + ' request friend with you'
  end

  def data
    @data ||= {
      type: TYPE[:friend],
      member_id: member.id,
      action: action,
      friend_id: a_member.id,
      worker: WORKER[:friends_request]
    }
  end

end
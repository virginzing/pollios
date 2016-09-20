class Notification::Group::Invite
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :friend_list, :group, :poke, :trigger

  def initialize(sender, friend_list, group, options = {})
    @sender = sender
    @friend_list = friend_list
    @group = group
    @poke = options[:poke] || false
    @trigger = options[:trigger] || false

    create(member_list, type, message, data)
  end

  def type
    'request'
  end

  def member_list
    friend_list
  end

  def message
    return invite_by_trigger_message if trigger
    return poke_invite_message if poke
    invite_message
  end

  def data
    @data ||= {
      type: TYPE[:group],
      group_id: group.id,
      group: GroupNotifySerializer.new(group).as_json,
      worker: WORKER[:invite_friend_to_group]
    }

    return @data.merge!(action: ACTION[:poke]) if poke
    @data.merge!(action: ACTION[:invite])
  end

  private

  def invite_by_trigger_message
    group.name + ' invited you join in group'
  end

  def poke_invite_message
    sender.fullname + " poke invited you join in \"#{group.name}\" group"
  end

  def invite_message
    sender.fullname + " invited you join in \"#{group.name}\" group"
  end
end
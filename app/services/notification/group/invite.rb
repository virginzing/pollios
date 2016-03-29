class Notification::Group::Invite
  include Notification::Helper
  include SymbolHash

  attr_reader :member, :friend_list, :group, :poke

  def initialize(member, friend_list, group, options = {})
    @member = member
    @friend_list = friend_list
    @group = group
    @poke = options[:poke] || false
    @trigger = options[:trigger] || false
  end

  def type
    'request'
  end

  def recipient_list
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
    group.name + 'invited you join in'
  end

  def poke_invite_message
    member.fullname + "poke invited you in: \"#{group_name}\""
  end

  def invite_message
    member.fullname + "invited you in: \"#{group_name}\""
  end
end
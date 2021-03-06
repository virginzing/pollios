class Notification::Group::PromoteAdmin
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :a_member, :group

  def initialize(sender, a_member, group)
    @sender = sender
    @a_member = a_member
    @group = group

    create(member_list, type, message, data)
  end

  def type
    nil
  end

  def member_list
    [a_member]
  end

  def message
    sender.fullname + " promoted you to administrator of #{group.name} group"
  end

  def data
    @data ||= {
      type: TYPE[:group],
      group_id: group.id,
      group: GroupNotifySerializer.new(group).as_json,
      action: ACTION[:promote_admin],
      worker: WORKER[:promote_admin]
    }
  end
end
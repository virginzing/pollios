class Notification::Group::PromoteAdmin
  include Notification::Helper
  include SymbolHash

  def initialize(member, a_member, group)
    @member = member
    @a_member = a_member
    @group = group

    create(recipient_list, type, message, data)
  end

  def type
    nil
  end

  def recipient_list
    [a_member]
  end

  def message
    member.fullname + " promoted you to administrator of #{@group.name} group"
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
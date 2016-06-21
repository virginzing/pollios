class Notification::Group::Join
  include Notification::Helper
  include SymbolHash

  attr_reader :member, :group

  def initialize(member, group)
    @member = member
    @group = group

    create_notification(recipient_list, type, message, data)
  end

  def type
    'join_group'
  end

  def recipient_list
    Group::MemberList.new(group, viewing_member: member).active
  end

  def message
    member.fullname + " joined #{group.name} group"
  end

  def data
    @data ||= {
      type: TYPE[:group],
      group_id: group.id,
      action: ACTION[:join],
      group: GroupNotifySerializer.new(group).as_json,
      worker: WORKER[:join_group]
    }
  end

end
class Notification::Group::JoinRequest
  include Notification::Helper
  include SymbolHash

  attr_reader :member, :group

  def initialize(member, group)
    @member = member
    @group = group

    create(recipient_list, type, message, data)
  end

  def type
    'request'
  end

  def recipient_list
    Group::MemberList.new(group, viewing_member: member).admins
  end

  def message
    member.fullname + " request to join #{group.name} group"
  end

  def data
    @data ||= {
      type: TYPE[:request_group],
      group_id: group.id,
      action: ACTION[:request],
      group: GroupNotifySerializer.new(group).as_json,
      worker: WORKER[:request_group]
    }
  end

end
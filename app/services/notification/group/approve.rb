class Notification::Group::Approve
  include Notification::Helper
  include SymbolHash

  attr_reader :member, :a_member, :group

  def initialize(member, a_member, group)
    @member = member
    @a_member = a_member
    @group = group

    create_notification(recipient_list, type, message, data)
  end

  def type
    'request'
  end

  def recipient_list
    [a_member]
  end

  def message
    member.fullname + " had approved your request to join #{group.name} group"
  end

  def data
    @data ||= {
      type: TYPE[:group],
      group_id: group.id,
      action: ACTION[:join],
      group: GroupNotifySerializer.new(group).as_json,
      worker: WORKER[:approve_request_group]
    }
  end

end
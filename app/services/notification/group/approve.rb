class Notification::Group::Approve
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
    'request'
  end

  def member_list
    [a_member]
  end

  def message
    sender.fullname + " approved your request to join in #{group.name} group"
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
class Notification::Group::JoinRequest
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :group

  def initialize(sender, group)
    @sender = sender
    @group = group

    create(member_list, type, message, data)
  end

  def type
    'request'
  end

  def member_list
    admins_of_group
  end

  def message
    sender.fullname + " request to join in #{group.name} group"
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

  private

  def admins_of_group
    Group::MemberList.new(group, viewing_member: sender).admins
  end

end
class Notification::Group::Join
  include Notification::NewHelper
  include SymbolHash

  attr_reader :sender, :group

  def initialize(sender, group)
    @sender = sender
    @group = group

    create(member_list, message, sender)
  end

  private

  def log?
    true
  end

  def alert_type
    'join_group'
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

  def member_list
    members_of_group
  end

  def message
    sender.fullname + " joined in #{group.name} group"
  end

  def members_of_group
    Group::MemberList.new(group, viewing_member: sender).active
  end

end
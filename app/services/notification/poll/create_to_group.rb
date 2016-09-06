class Notification::Poll::CreateToGroup
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :poll, :group_list

  def initialize(member, poll, group_list)
    @sender = member
    @poll = poll
    @group_list = group_list

    members_of_all_group.each do |recipient|
      create(recipient, type, message_for(recipient), data)
    end
  end

  def type
    'group'
  end

  def recipient_list
    members_of_all_group
  end

  def message_for(recipient)
    available_groups = Member::GroupList.new(recipient).groups_available_for_poll(poll)

    case available_groups.size

    when 1
      groups = available_groups.first.name
    else
      groups = "#{available_groups.size} groups"
    end

    sender.fullname + " asked in #{groups} \"#{poll.title}\""
  end

  def data
    @data ||= {
      type: TYPE[:poll],
      poll_id: poll.id,
      poll: PollSerializer.new(poll).as_json,
      series: poll.series,
      action: ACTION[:create],
      worker: WORKER[:poll],
      group_id: group.id,
      group: GroupNotifySerializer.new(group).as_json
    }
  end

  private

  def members_of_all_group
    group_list.map { |group| Group::MemberList.new(group, viewing_member: sender).active }.flatten.uniq
  end

end
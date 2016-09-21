class Notification::Poll::CreateToGroup
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :poll, :group_list

  def initialize(sender, poll, group_list)
    @sender = sender
    @poll = poll
    @group_list = group_list

    member_list.each do |member|
      create(member, type, message_for(member), data)
    end
  end

  def type
    'group'
  end

  def member_list
    members_of_groups
  end

  def message_for(member)
    available_groups = Member::GroupList.new(member).groups_available_for_poll(poll)

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
      worker: WORKER[:poll]
    }
  end

  private

  def members_of_groups
    group_list.map { |group| Group::MemberList.new(group, viewing_member: sender).active }.flatten.uniq
  end

end
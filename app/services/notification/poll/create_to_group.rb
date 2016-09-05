class Notification::Poll::CreateToGroup
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :poll, :group

  def initialize(member, poll, group)
    @sender = member
    @poll = poll
    @group = group

    create(recipient_list, type, message, data)
  end

  def type
    'group'
  end

  def recipient_list
    members_of_group - blocked_members
  end

  def message
    sender.fullname + " asked in #{group.name}: \"#{poll.title}\""
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

  def members_of_group
    group_member_listing_service = Group::MemberList.new(group)
  end

  def blocked_members
    member_listing_service = Member::MemberList.new(sender)
    
    member_listing_service.blocks | Member.find(member_listing_service.blocked_by_someone)
  end

end
class Notification::Poll::Create
  include Notification::Helper
  include SymbolHash

  attr_reader :member, :poll

  def initialize(member, poll)
    @member = member
    @poll = poll

    create(recipient_list, type, message, data)
  end

  def type
    return 'public' if poll.public
    'friend'
  end

  def recipient_list
    member_listing_service = Member::MemberList.new(member)
    blocked_members = member_listing_service.blocks | Member.find(member_listing_service.blocked_by_someone)

    return Member.all - blocked_members if poll.public

    recipient_list = member_listing_service.friends
    recipient_list << member_listing_service.followers unless member.citizen?

    recipient_list - blocked_members
  end

  def message
    member.fullname + " added a new poll: \"#{poll.title}\""
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

end
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
    recipient_list = poll.public ? all_member : friends_and_followers

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

  private

  def all_member
    Member.all
  end

  def member_listing_service
    Member::MemberList.new(member)
  end

  def friends_and_followers
    friends = member_listing_service.friends
    followers = member_listing_service.followers

    member.citizen? ? friends : (friends | followers)
  end

  def blocked_members
    member_listing_service.blocks | Member.find(member_listing_service.blocked_by_someone)
  end
end
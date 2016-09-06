class Notification::Poll::Create
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :poll

  def initialize(member, poll)
    @sender = member
    @poll = poll

    create(recipient_list, type, message, data)
  end

  def type
    return 'public' if poll.public
    'friend'
  end

  def recipient_list
    poll.public ? all_member : friends_and_followers
  end

  def message
    sender.fullname + " added a new poll: \"#{poll.title}\""
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
    Member.viewing_by_member(sender)
  end

  def member_listing_service
    Member::MemberList.new(sender, viewing_member: sender)
  end

  def friends_and_followers
    friends = member_listing_service.friends
    followers = member_listing_service.followers

    sender.citizen? ? friends : (friends | followers)
  end
end
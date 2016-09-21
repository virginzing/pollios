class Notification::Poll::Create
  include Notification::Helper
  include SymbolHash

  attr_reader :sender, :poll

  def initialize(sender, poll)
    @sender = sender
    @poll = poll

    create(member_list, type, message, data)
  end

  def type
    return 'public' if public_poll?
    'friend'
  end

  def member_list
    public_poll? ? all_member : friends_and_followers
  end

  def message
    sender.fullname + " asked \"#{poll.title}\""
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

  def public_poll?
    poll.public
  end

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
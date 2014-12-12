class V6::PublicTimeline
  include GroupApi
  include Timelinable

  TYPE_TIMELINE = 'public_timeline'

  attr_accessor :list_polls, :list_shared, :order_ids, :next_cursor

  def initialize(member, options)
    @member = member
    @options = options
    @next_cursor = 0
    @list_polls = []
    @list_shared = []
    @order_ids = []
  end

  def get_timeline
    split_poll_and_filter(TYPE_TIMELINE)
  end

  def total_entries
    cached_poll_ids_of_poll_member(TYPE_TIMELINE).count
  end

  private

  def find_poll_public
    query_poll_public = "poll_members.public = 't' AND poll_members.share_poll_of_id = 0 AND poll_members.in_group = 'f'"
    
    query = PollMember.available.unexpire.joins(:poll).where("(#{query_poll_public})")

    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0

    query = query.limit(LIMIT_TIMELINE) 

    ids = query.map(&:id)
  end

  def main_timeline
    find_poll_public
  end

end
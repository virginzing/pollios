class WatchPoll
  def initialize(member, poll_id)
    @member = member
    @poll_id = poll_id
  end

  def watching
    if find_watch_poll.present?
      watching = find_watch_poll.update!(poll_notify: true, comment_notify: true)
    else
      watching = @member.watcheds.create!(poll_id: @poll_id, poll_notify: true, comment_notify: true)
    end
    # @member.flush_cache_my_watch
    FlushCached::Member.new(@member).clear_list_watched_polls
    watching
  end

  def unwatch
    if find_watch_poll
      unwatch = find_watch_poll.update!(poll_notify: false, comment_notify: false)
      # @member.flush_cache_my_watch
      FlushCached::Member.new(@member).clear_list_watched_polls
    end
    unwatch
  end

  private

  def find_watch_poll
    @member.watcheds.find_by(poll_id: @poll_id)
  end

end

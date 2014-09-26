class WatchPoll
  def initialize(member, poll_id)
    @member = member
    @poll_id = poll_id
  end

  def watching
    unless find_watch_poll
      watching = @member.watcheds.create!(poll_id: @poll_id)
    end
    watching
  end

  def unwatch
    if find_watch_poll
      unwatch = find_watch_poll.update!(poll_notify: false)
    end
    unwatch
  end

  private

  def find_watch_poll
    @member.watcheds.find_by(poll_id: @poll_id, poll_notify: true)
  end

end

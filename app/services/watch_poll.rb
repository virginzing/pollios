class WatchPoll
  def initialize(member, poll_id)
    @member = member
    @poll_id = poll_id
  end

  def watching
    if find_watch_poll.present?
      watching = find_watch_poll.update!(poll_notify: true)
    else
      watching = @member.watcheds.create!(poll_id: @poll_id)
    end
    Rails.cache.delete([ @member.id, "watcheds" ])
    watching
  end

  def unwatch
    if find_watch_poll
      unwatch = find_watch_poll.update!(poll_notify: false)
      Rails.cache.delete([ @member.id, "watcheds" ])
      unwatch
    end
  end

  private

  def find_watch_poll
    @member.watcheds.find_by(poll_id: @poll_id)
  end

end

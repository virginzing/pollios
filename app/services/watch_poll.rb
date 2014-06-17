class WatchPoll
  def initialize(member, poll_id)
    @member = member
    @poll_id = poll_id
  end

  def watching
    unless find_watch
       watching = @member.watcheds.create!(poll_id: @poll_id)
    end
    watching
  end

  def unwatch
    if find_watch
      unwatch = find_watch.destroy
    end
    unwatch
  end

  private

  def find_watch
    @member.watcheds.find_by(poll_id: @poll_id)
  end
  
end

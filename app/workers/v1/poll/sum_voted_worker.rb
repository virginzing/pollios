class V1::Poll::SumVotedWorker
  include Sidekiq::Worker

  def perform(poll_id)
    poll = Poll.cached_find(poll_id)
    Notification::Poll::SumVoted.new(poll)
  end
end
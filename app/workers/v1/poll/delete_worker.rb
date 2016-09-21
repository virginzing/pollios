class V1::Poll::DeleteWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(poll_id)
    poll = Poll.cached_find(poll_id)

    NotifyLog.update_deleted_poll(poll)
  end
end
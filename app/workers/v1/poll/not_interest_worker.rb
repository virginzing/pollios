class V1::Poll::NotInterestWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform_async(poll_id, member_id)
    poll = Poll.cached_find(poll_id)
    member = Member.cached_find(member_id)

    NotifyLog.update_deleted_poll_for_member(poll, member)
  end
end
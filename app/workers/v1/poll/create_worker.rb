class V1::Poll::CreateWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, poll_id)
    member = Member.cached_find(member_id)
    poll = Poll.cached_find(poll_id)

    Notification::Poll::Create.new(member, poll)
  end
end
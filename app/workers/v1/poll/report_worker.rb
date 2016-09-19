class V1::Poll::ReportWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, poll_id, reason_message)
    member = Member.cached_find(member_id)
    poll = Poll.cached_find(poll_id)

    Notification::Poll::Report.new(member, poll, reason_message)
  end

end
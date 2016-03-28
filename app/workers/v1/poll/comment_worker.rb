class V1::Poll::CommentWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, poll_id, comment_message)
    member = Member.cached_find(member_id)
    poll = Poll.cached_find(poll_id)

    Notification::Poll::Comment.new(member, poll, comment_message)
  end
end
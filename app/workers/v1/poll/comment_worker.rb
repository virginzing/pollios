class V1::Poll::CommentWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, comment_id)
    member = Member.cached_find(member_id)
    comment = Comment.cached_find(comment_id)

    Notification::Poll::Comment.new(member, comment)
  end
end
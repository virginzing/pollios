class V1::Poll::DeleteCommentWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(comment_id)
    comment = Comment.cached_find(comment_id)

    NotifyLog.update_deleted_comment(comment)
  end
end
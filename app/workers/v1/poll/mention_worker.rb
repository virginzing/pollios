class V1::Poll::Mentionworker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, comment_id, mention_ids)
    member = Member.cached_find(member_id)
    comment = Comment.cached_find(comment_id)
    mention_list = Member.find(mention_ids)

    Notification::Poll::Mention.new(member, comment, mention_list)
  end
end
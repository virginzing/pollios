class V1::Member::CancelFriendRequestWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, a_member_id)
    member = Member.cached_find(member_id)
    a_member = Member.cached_find(a_member_id)

    NotifyLog.update_cancel_friend_request(member, a_member)
  end
end
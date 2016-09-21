class V1::Member::CancelFriendRequestWorker

  def perform_async(member_id, a_member_id)
    member = Member.cached_find(member_id)
    a_member = Member.cached_find(a_member_id)

    NotifyLog.update_cancel_friend_request(member, a_member)
  end
end
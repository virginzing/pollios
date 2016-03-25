class V1::Member::FriendsRequestWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, a_member_id, options = {})
    member = Member.cached_find(member_id)
    a_member = Member.cached_find(a_member_id)
    Notification::Member::FriendsRequest.new(member, a_member, options)
  end
end
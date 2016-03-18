class V1::FriendRequestWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member, a_member, options = {})
    Notification::Member::FriendsRequest.new(member, a_member, options)
  end
end
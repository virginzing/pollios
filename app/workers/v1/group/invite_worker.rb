class V1::Group::InviteWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, friend_ids, group_id, options = {})
    member = Member.cached_find(member_id)
    friend_list = Member.find(friend_ids)
    group = Group.cached_find(group_id)

    Notification::Group::Invite.new(member, friend_list, group, options)
  end
end
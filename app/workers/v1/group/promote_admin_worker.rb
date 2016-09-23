class V1::Group::PromoteAdminWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, a_member, group_id)
    member = Member.cached_find(member_id)
    a_member = Member.cached_find(a_member_id)
    group = Group.cached_find(group_id)

    Notification::Group::PromoteAdmin.new(member, a_member, group)
  end
end
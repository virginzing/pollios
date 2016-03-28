class V1::Group::JoinWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, group_id)
    member = Member.cached_find(member_id)
    group = Group.cached_find(group_id)

    Notification::Group::Join.new(member, group)
  end
end
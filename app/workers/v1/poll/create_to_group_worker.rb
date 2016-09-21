class V1::Poll::CreateToGroupWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, poll_id, group_ids)
    member = Member.cached_find(member_id)
    poll = Poll.cached_find(poll_id)
    group_list = Group.find(group_ids)

    Notification::Poll::CreateToGroup.new(member, poll, group_list)
  end
end
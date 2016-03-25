class V1::Poll::CreateInGroupWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, poll_id, group_id)
    member = Member.cached_find(member_id)
    poll = Poll.cached_find(poll_id)
    group = Group.cached_find(group_id)

    Notification::Poll::NewPollInGroup.new(member, poll, group)
  end
end
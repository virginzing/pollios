class V1::Group::CancelRequestWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform(member_id, group_id)
    member = Member.cached_find(member_id)
    group = Group.cached_find(group_id)

    NotifyLog.update_cancel_request_to_join_group(member, group)
  end
end
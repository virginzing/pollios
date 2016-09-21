class V1::Group::CancelInvitationWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  def perform_async(invitation_sender_id, member_id, group_id)
    invitation_sender = Member.cached_find(invitation_sender_id)
    member = Member.cached_find(member_id)
    group = Group.cached_find(group_id)

    NotifyLog.update_cancel_invitation_to_group(invitation_sender, member, group)
  end
end
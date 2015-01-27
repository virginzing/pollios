class InviteGroup
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member_id, friend_ids, group)
    @member_id = member_id
    @friend_ids = friend_ids
    @group = group
  end

  def recipient_ids
    if @friend_ids.present?
      apn_friend_ids
    end
  end

  def member_name
    member.fullname
  end

  def group_name
    @group.name
  end

  def custom_message
    message = "#{member_name} invited you in: \"#{group_name}\""
    truncate_message(message)
  end
  
  private

  def member
    Member.find(@member_id)
  end

  def apn_friend_ids
    # Member.where(id: @friend_ids, apn_invite_group: true).pluck(:id)
    Member.where(id: @friend_ids, receive_notify: true).pluck(:id).uniq
  end

end
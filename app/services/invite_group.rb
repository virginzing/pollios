class InviteGroup
  include ActionView::Helpers::TextHelper

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
    member.sentai_name.split(%r{\s}).first
  end

  def group_name
    truncate(@group.name, length: 10)
  end

  def custom_message
    member_name + " invited you to the " + group_name
  end

  private

  def member
    Member.find(@member_id)
  end

  def apn_friend_ids
    Member.where(id: @friend_ids, apn_invite_group: true).pluck(:id)
  end

end
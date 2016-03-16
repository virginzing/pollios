class InviteGroup
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member_id, friend_ids, group, options = {})
    @member_id = member_id
    @friend_ids = friend_ids
    @group = group
    @options = options
  end

  def recipient_ids
    if @friend_ids.present?
      apn_friend_ids
    end
  end

  def receive_notification
    member_open_notification
  end

  def member_name
    member.fullname
  end

  def group_name
    @group.name
  end

  def custom_message
    if @member_id == 0
      message = "\"#{group_name}\" invited you join in"
    else
      if @options[:poke]
        message = "#{member_name} poke invited you in: \"#{group_name}\""
      else
        message = "#{member_name} invited you in: \"#{group_name}\""
      end
    end

    truncate_message(message)
  end

  private

  def member
    Member.find(@member_id)
  end

  def apn_friend_ids
    Member.where(id: @friend_ids).pluck(:id).uniq
  end

  def member_open_notification
    list_members = Member.where(id: apn_friend_ids)
    getting_notification(list_members, "request")
  end

end

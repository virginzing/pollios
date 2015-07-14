class AskQuestionnaire
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll_series, group)
    @member = member
    @poll_series = poll_series
    @group = group
  end

  def recipient_ids
    @group.present? ? group_member_ids : []
  end

  def receive_notification
    list_members = Member.where(id: recipient_ids)
    getting_notification(list_members, "group")
  end

  def member_name
    @member.fullname
  end

  def group_name
    @group.name
  end

  def custom_message
    message = "A Questionnaire in #{group_name}: \"#{@poll_series.description}\""
    truncate_message(message)
  end

  private

  def group_member_ids
    received_notify_of_member_ids(@group.get_member_active) - [@member.id]
  end

end

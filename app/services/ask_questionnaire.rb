class AskQuestionnaire
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll_series, group)
    @member = member
    @poll_series = poll_series
    @group = group
  end

  def group_member_ids
    @group.get_member_open_notification.collect(&:id).flatten - [@member.id]
  end
  
  def recipient_ids
    @group.present? ? group_member_ids : []
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

end

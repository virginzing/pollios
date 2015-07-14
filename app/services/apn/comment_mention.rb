class Apn::CommentMention
  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(mentioner, poll, mentionable_list)
    @mentioner = mentioner
    @poll = poll
    @mentionable_list = mentionable_list
  end

  def mentioner_name
    @mentioner.fullname
  end

  def receive_notification
    list_members = Member.where(id: @mentionable_list)
    getting_notification(list_members, "watch_poll")
  end

  def custom_message
    message = "#{mentioner_name} mentioned you in a comment"
    truncate_message(message)
  end

end

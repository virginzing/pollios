class Apn::CommentMention
  include SymbolHash
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(mentioner, poll)
    @mentioner = mentioner
    @poll = poll
  end

  def mentioner_name
    @mentioner.fullname
  end

  def custom_message
    message = "#{mentioner_name} mentioned you in a comment"
    truncate_message(message)
  end
end

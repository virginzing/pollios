class Apn::PokePoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(poll)
    @poll = poll
  end

  def custom_message

    message = "Please vote poll: \"#{@poll.title}\""

    truncate_message(message)
  end
  
  
end
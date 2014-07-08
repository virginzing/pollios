class Apn::VotePoll
  include ActionView::Helpers::TextHelper
  include NotificationsHelper

  def initialize(member, poll)
    @member = member
    @poll = poll
    @is_public = false
    @in_group = false
  end

  def member_id
    @member.id
  end

  def member_name
    @member.fullname
  end

  def recipient_ids
    watched_poll
  end
  
  # allow 170 byte for custom message
  def custom_message
    which_poll

    message = "#{fullname_of_voter} votes a poll: \"#{@poll.title}\""

    truncate_message(message)
  end

  def which_poll
    if @poll.in_group_ids != "0"
      @in_group = true
    else
      if @poll.public
        @is_public = true
      end
    end
  end

  def fullname_of_voter
    if @in_group
      @member.anonymous_group ? 'Someone' : @member.fullname
    elsif @is_public
      @member.anonymous_public ? 'Someone' : @member.fullname
    else
      @member.anonymous_friend_following ? 'Someone' : @member.fullname
    end
  end

  private

  def watched_poll
    Watched.where(poll_id: @poll.id, poll_notify: true).pluck(:member_id)
  end
  
end

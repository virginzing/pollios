class Member::Notification

  attr_accessor :options

  DEFAULT = {
    "public" => "false",
    "group" => "true",
    "friend" => "true",
    "watch_poll" => "true",
    "request" => "true",
    "join_group" => "false"
  }

  def initialize(member, options = DEFAULT)
    @member = member
    @options = options
  end

  def update!
    @member.notification = options
    @member.save!
  end

end

class Member::Notification

  attr_accessor :options

  DEFAULT = {
    "public" => "0",
    "group" => "1",
    "friend" => "1",
    "watch_poll" => "1",
    "request" => "1",
    "join_group" => "0"
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
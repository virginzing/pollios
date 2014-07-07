class PollMember < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll, -> { having_status_poll(:gray, :white) }, touch: true

  scope :active, -> { where("poll_members.expire_date > ?", Time.now) }
  scope :inactive, -> { where("expire_date < ?", Time.now) }
  scope :hidden, -> (hidden_poll) { where("poll_id NOT IN (?)", hidden_poll) }

  scope :available, -> {
    member_report_poll = Member.reported_polls.map(&:id)  ## poll ids
    member_block = Member.list_friend_block.map(&:id)  ## member ids

    if member_report_poll.present? && member_block.present?
      where("#{table_name}.poll_id NOT IN (?) AND #{table_name}.member_id NOT IN (?)", member_report_poll, member_block)
    elsif member_report_poll.present?
      where("#{table_name}.poll_id NOT IN (?)", member_report_poll)
    elsif member_block.present?
      where("#{table_name}.member_id NOT IN (?)", member_block)
    end 
  }

  LIMIT_TIMELINE = 3000

  def self.find_poll_celebrity_or_public(type)
    celebrtiy = Member.having_member_type(:celebrity).pluck(:id)
    query = where("(member_id IN (?) OR public = ?) AND share_poll_of_id = 0", celebrtiy, true).limit(LIMIT_TIMELINE)    
    find_poll_member = check_hidden(query)
    filter_type(find_poll_member, type).map(&:id)
  end

  def self.find_poll_following(member_obj, type)
    following = member_obj.get_following.map(&:id)
    query = where("(member_id IN (?)) AND share_poll_of_id = 0 AND in_group = ?", following, false).limit(LIMIT_TIMELINE)   
    find_poll_member = check_hidden(query)
    filter_type(find_poll_member, type).map(&:id)
  end

  def self.find_poll_original(member_id, friend_id, type)
    query = where("(member_id = ? OR member_id IN (?)) AND share_poll_of_id = 0 AND in_group = ?", member_id, friend_id, false).limit(LIMIT_TIMELINE)
    find_poll = check_hidden(query)
    @poll = filter_type(find_poll, type)
    ids = @poll.map(&:id)
    poll_ids = @poll.map(&:poll_id)
    return ids, poll_ids
  end

  def self.find_poll_shared(friend_id, type)
    query = where("member_id IN (?) AND share_poll_of_id != 0", friend_id).limit(LIMIT_TIMELINE)
    find_poll_shared = check_hidden(query)
    @poll = filter_type(find_poll_shared, type)
    @poll.collect{|poll| [poll.id, poll.share_poll_of_id]}.sort! {|x,y| y.first <=> x.first }.uniq {|s| s.last }
  end

  def self.find_my_poll(member_id, type)
    query =  where("member_id = ? AND share_poll_of_id = 0", member_id).order("id desc").limit(LIMIT_TIMELINE)
    find_poll = check_hidden(query)
    filter_type(find_poll, type).map(&:poll_id)
  end

  def self.timeline(member_id, friend_id, type)
    @hidden_poll = HiddenPoll.my_hidden_poll(member_id)

    ids, poll_ids = find_poll_original(member_id, friend_id, type)
    list_ids = ids | find_poll_celebrity_or_public(type)
    # puts "poll normal : #{ids}, #{poll_ids}"
    shared = find_poll_shared(friend_id, type)

    # puts "shared: #{shared}"
    # puts "list_ids : #{list_ids}"
    # puts "poll_ids : #{poll_ids}"
    poll_ids_sort = (shared.delete_if {|id| id.first if poll_ids.include?(id.last) }.collect {|e| e.first } + list_ids).sort! { |x,y| y <=> x }
    # puts "poll_ids_sort: #{poll_ids_sort}"
    poll_ids_sort
  end

  def self.friend_following_timeline(member_obj, member_id, friend_id, type)
    @hidden_poll = HiddenPoll.my_hidden_poll(member_id)

    ids, poll_ids = find_poll_original(member_id, friend_id, type)

    list_ids = ids | find_poll_following(member_obj, type)
    
    shared = find_poll_shared(friend_id, type)
    poll_ids_sort = (shared.delete_if {|id| id.first if poll_ids.include?(id.last) }.collect {|e| e.first } + list_ids).sort! { |x,y| y <=> x }

    poll_ids_sort
  end


  def self.public_timeline(member_id, type)
    @hidden_poll = HiddenPoll.my_hidden_poll(member_id)

  end

  def self.check_hidden(query)
    @hidden_poll.empty? ? query : query.hidden(@hidden_poll)
  end


  def self.filter_type(query, type)
    case type
      when "active" then query.active
      when "inactive" then query.inactive
      else query
    end
  end

end

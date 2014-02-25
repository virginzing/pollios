class PollMember < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll

  scope :active, -> { where("expire_date > ?", Time.now) }
  scope :inactive, -> { where("expire_date < ?", Time.now) }

  LIMIT_TIMELINE = 3000

  def self.find_poll_celebrity_or_public(type)
    celebrtiy = Member.having_member_type(:celebrity).pluck(:id)
    find_poll_member = where("(member_id IN (?) OR public = ?) AND share_poll_of_id = 0", celebrtiy, true).limit(LIMIT_TIMELINE)

    filter_type(find_poll_member, type).map(&:id)
  end

  def self.find_poll_original(member_id, friend_id, type)
    find_poll = where("(member_id = ? OR member_id IN (?)) AND share_poll_of_id = 0", member_id, friend_id).limit(LIMIT_TIMELINE)
    @poll = filter_type(find_poll, type)

    ids = @poll.map(&:id)
    poll_ids = @poll.map(&:poll_id)
    return ids, poll_ids
  end

  def self.find_poll_shared(friend_id, type)
    find_poll_shared = where("member_id IN (?) AND share_poll_of_id != 0",friend_id).limit(LIMIT_TIMELINE)
    @poll = filter_type(find_poll_shared, type)
    @poll.collect{|poll| [poll.id, poll.share_poll_of_id]}.sort! {|x,y| y.first <=> x.first }.uniq {|s| s.last }
  end

  def self.timeline(member_id, friend_id, type)

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


  def self.filter_type(query, type)
    case type
      when "active" then query.active
      when "inactive" then query.inactive
      else query
    end
  end

end

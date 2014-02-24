class PollMember < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll

  def self.find_poll_celebrity
    celebrtiy = Member.having_member_type(:celebrity).pluck(:id)
    where("member_id IN (?) AND share_poll_of_id = 0", celebrtiy).map(&:id)
  end

  def self.find_poll_original(member_id, friend_id)
    find_poll = where("(member_id = ? OR member_id IN (?)) AND share_poll_of_id = 0", member_id, friend_id)
    ids = find_poll.map(&:id)
    poll_ids = find_poll.map(&:poll_id)
    return ids, poll_ids
  end

  def self.find_poll_shared(friend_id)
    where("member_id IN (?) AND share_poll_of_id != 0",friend_id).collect{|poll| [poll.id, poll.share_poll_of_id]}.uniq {|s| s.last }
  end

  def self.timeline(member_id, friend_id)
    ids, poll_ids = find_poll_original(member_id, friend_id)
    list_ids = ids + find_poll_celebrity

    shared = find_poll_shared(friend_id)
    # puts "shared: #{shared}"
    # puts "list_ids : #{list_ids}"
    # puts "poll_ids : #{poll_ids}"
    poll_ids_sort = (shared.delete_if {|id| id.first if poll_ids.include?(id.last) }.collect {|e| e.first } + list_ids).sort! { |x,y| y <=> x }
    # puts "poll_ids_sort: #{poll_ids_sort}"
    poll_ids_sort
  end

end

class OverallTimeline

  attr_reader :type
  LIMIT_TIMELINE = 3000

  def initialize(member_obj, params)
    @member = member_obj
    @params = params
    @hidden_poll = HiddenPoll.my_hidden_poll(member_obj.id)
    @your_group = member_obj.get_group_active
  end

  def member_id
    @member.id
  end

  def your_friend_ids
    @friend_ids ||= @member.whitish_friend.map(&:followed_id)
  end

  def your_group_ids
    @group_poll_ids ||= @your_group.pluck(:id)  
  end

  def group_by_name
    Hash[@your_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "photo" => f.get_photo_group, "member_count" => f.member_count, "poll_count" => f.poll_count]] }]
  end

  def overall_timeline
    ids, poll_ids = find_poll_me_and_friend_and_group_and_public
    shared = find_poll_share
    poll_member_ids_sort = (shared.delete_if {|id| id.first if poll_ids.include?(id.last) }.collect {|e| e.first } + ids).sort! { |x,y| y <=> x }
  end

  private

  def find_poll_me_and_friend_and_group_and_public
    query = PollMember.where("(((member_id = ? OR member_id IN (?)) AND in_group = ?) OR (poll_id IN (?) AND in_group = ?) OR (public = ? AND in_group = ?)) AND share_poll_of_id = ?", 
      member_id, your_friend_ids, false, find_poll_in_my_group, true, true, false, 0).limit(LIMIT_TIMELINE)

    poll_member = check_hidden_poll(query)
    ids, poll_ids = poll_member.map(&:id), poll_member.map(&:poll_id)
  end

  def find_poll_in_my_group
    query = PollGroup.where("group_id IN (?)", your_group_ids).limit(LIMIT_TIMELINE).map(&:poll_id)
  end

  def find_poll_share
    query = PollMember.where("member_id IN (?) AND share_poll_of_id != ?", your_friend_ids, 0).limit(LIMIT_TIMELINE)
    poll_member = check_hidden_poll(query)
    poll_member.collect{|poll| [poll.id, poll.share_poll_of_id]}.sort! {|x,y| y.first <=> x.first }.uniq {|s| s.last }
  end
  
  def check_hidden_poll(query)
    @hidden_poll.empty? ? query : query.hidden(@hidden_poll)
  end
  
end
class Friend::ListGroup
  def initialize(member, friend)
    @member = member
    @friend = friend
  end

  def my_group_id
    @my_group_ids ||= my_group.map(&:id)  
  end

  def friend_group_id
    @friend_group_ids ||= friend_group.map(&:id)
  end

  def my_and_friend_group
    my_group_id & friend_group_id
  end

  def together_group
    @together_group ||= groups 
  end

  def hash_member_count
    @group_member_count ||= group_member_count.inject({}) { |h,v| h[v.id] = v.member_count; h }
  end

  private

  def groups
    Group.joins(:group_members_active).select("groups.*, group_members.is_master as member_admin") \
          .where("(groups.id IN (?) AND group_members.member_id = #{@friend.id}) OR (groups.public = 't' AND group_members.member_id = #{@friend.id})", my_and_friend_group) \
          .group("groups.id, member_admin")
  end

  def group_member_count
    Group.joins(:group_members_active).select("groups.*, count(group_members) as member_count").group("groups.id") \
          .where("groups.id IN (?)", together_group.map(&:id))
  end

  def my_group
    init_list_group = Member::ListGroup.new(@member)
    init_list_group.active
  end

  def friend_group
    init_list_group = Member::ListGroup.new(@friend)
    init_list_group.active_with_private
  end
  
end
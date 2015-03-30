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

  ## together group of citizen and celebrity

  def together_group_of_friend
    @together_group_of_friend ||= groups_of_friend 
  end

  def together_group_of_friend_non_virtual
    @together_group_of_friend_non_virtual ||= groups_of_friend.select{|group| group unless group.virtual_group } 
  end

  def hash_member_count_of_friend
    @hash_member_count_of_friend ||= group_of_friend_count.inject({}) { |h,v| h[v.id] = v.member_count; h }
  end


  ## together group of official

  def together_group_of_official
    @together_group_of_official ||= group_of_official
  end

  def together_group_of_official_non_virtual
    @together_group_of_official_non_virtual ||= group_of_official.select{|group| group unless group.virtual_group } 
  end

  def hash_member_count_of_official
    @hash_member_count_of_official ||= group_of_official_count.inject({}) { |h,v| h[v.id] = v.member_count; h }
  end

  private

  def group_of_official
    Group.where("(groups.id IN (?) AND groups.public = 't') OR (groups.member_id = #{@friend.id} AND groups.public = 't')", @friend.company.group_companies.map(&:group_id)).uniq
  end

  def group_of_official_count
    Group.joins(:group_members_active).select("groups.*, count(group_members) as member_count").group("groups.id") \
          .where("groups.id IN (?)", together_group_of_official.map(&:id)).uniq
  end

  def groups_of_friend
    Group.joins(:group_members_active).select("groups.*, group_members.is_master as member_admin") \
          .where("(groups.id IN (?) AND group_members.member_id = #{@friend.id}) OR (groups.public = 't' AND group_members.member_id = #{@friend.id})", my_and_friend_group) \
          .group("groups.id, member_admin").uniq
  end

  def group_of_friend_count
    Group.joins("left join group_members on group_members.group_id = groups.id").select("groups.*, count(group_members) as member_count").group("groups.id") \
          .where("groups.id IN (?)", together_group_of_friend.map(&:id)).uniq
  end

  def my_group
    init_list_group = Member::ListGroup.new(@member)
    init_list_group.active
  end

  def friend_group
    init_list_group = Member::ListGroup.new(@friend)
    init_list_group.active_with_public
  end
  
end
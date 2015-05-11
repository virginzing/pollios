class Member::ListGroup
  def initialize(member)
    @member = member
  end

  def cached_all_groups
    @cached_all_groups ||= cached_groups
  end

  def active
    cached_all_groups.select{|group| group if group.member_is_active }
  end

  def active_non_virtual
    cached_all_groups.select{|group| group if group.member_is_active  && !group.virtual_group }
  end

  def active_with_public
    cached_all_groups.select{|group| group if group.member_is_active && group.public == false }  
  end

  def inactive
    cached_all_groups.select{|group| group unless group.member_is_active }
  end

  def hash_member_count
    @group_member_count ||= group_member_count.inject({}) { |h,v| h[v.id] = v.member_count; h }
  end

  private

  def groups
    Group.joins(:group_members).select("groups.*, group_members.is_master as member_admin, group_members.active as member_is_active, group_members.invite_id as member_invite_id") \
          .where("group_members.member_id = #{@member.id}").group("groups.id, member_admin, member_is_active, member_invite_id")
  end

  def group_member_count
    Group.joins(:group_members_active).select("groups.*, count(group_members) as member_count").group("groups.id") \
          .where("groups.id IN (?)", cached_all_groups.map(&:id))
  end
  
  def cached_groups
    Rails.cache.fetch("member/#{@member.id}/groups") do
      groups.to_a
    end
  end
  
end
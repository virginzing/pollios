class Member::ListGroup
  def initialize(member)
    @member = member
  end

  def cached_all_groups
    @cached_all_groups ||= cached_groups
  end

  def active
    cached_all_groups.select{|group| group if group.member_active }
  end

  def inactive
    cached_all_groups.select{|group| group unless group.member_active }
  end

  private

  def groups
    Group.joins(:group_members).select("groups.*, group_members.is_master as member_admin, group_members.active as member_active, group_members.invite_id as member_invite_id") \
          .where("group_members.member_id = #{@member.id}").group("groups.id, member_admin, member_active, member_invite_id")
  end
  
  def cached_groups
    Rails.cache.fetch("member/#{@member.id}/groups") do
      groups.to_a
    end
  end
  
end

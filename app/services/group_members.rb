class GroupMembers
  def initialize(group)
    @group = group
  end

  def list_members
    @list_members ||= members
  end

  def cached_all_members
    @cached_all_members ||= cached_members
  end

  def active
    cached_all_members.select{|member| member if member.is_active }
  end

  def pending
    cached_all_members.select{|member| member unless member.is_active }
  end

  def members_as_member
    cached_all_members.select{ |member| member unless member.admin }
  end

  def members_as_admin
    cached_all_members.select{ |member| member if member.admin }
  end

  private

  def members
    Member.joins(:group_members).where("group_members.group_id = #{@group.id}")
          .select(
            "DISTINCT members.*, 
            group_members.is_master as admin, 
            group_members.active as is_active").order("members.fullname asc")
  end
  
  def cached_members
    Rails.cache.fetch("/group/#{@group.id}-#{@group.updated_at.to_i}/members", :expires_in => 12.hours) do
      members.to_a
    end
  end
  
end
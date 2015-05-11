class Group::ListMember
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

  def join_recently
    active.sort {|x,y| y.join_at <=> x.join_at }[0..4]
  end

  def is_member?(member)
    members_as_member.map(&:id).include?(member.id) ? true : false
  end

  def is_admin?(member)
    members_as_admin.map(&:id).include?(member.id) ? true : false  
  end

  private

  def members
    Member.joins(:group_members).where("group_members.group_id = #{@group.id}")
          .select("DISTINCT members.*, group_members.is_master as admin, group_members.active as is_active, group_members.created_at as join_at").order("members.fullname asc")
  end
  
  def cached_members
    Rails.cache.fetch("group/#{@group.id}/members") do
      members.to_a
    end
  end
  
end
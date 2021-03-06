class FlushCached::Group
  def initialize(group)
    @group = group
  end

  def clear_list_group_all_member_in_group
    list_member_in_group = Group::MemberList.new(@group)

    list_member_in_group.all.each do |member|
      FlushCached::Member.new(member).clear_list_groups
    end
  end

  def clear_list_members
    Rails.cache.delete("group/#{@group.id}/members")
  end

  def clear_list_requests
    Rails.cache.delete("group/#{@group.id}/requests")
  end
  
end

# FlushCached::Group.new(Group.find(119)).clear_list_members
class FlushCached::Group
  def initialize(member)
    @member = member
  end


  def clear_list_members
    @member.cached_get_group_active.each do |group|
      group.touch
    end
  end
  
end
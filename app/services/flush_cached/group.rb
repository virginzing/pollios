class FlushCached::Group
  def initialize(member)
    @member = member
  end


  def clear_list_members
    init_list_group = Member::ListGroup.new(@member)

    init_list_group.active.each do |group|
      group.touch
    end
    
  end

  
end
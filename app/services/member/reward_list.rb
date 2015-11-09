class Member::RewardList

  def initialize(member, options = {})
    @member = member
    if options[:page_index]
    	@page_index = options[:page_index]
    else
    	@page_index = 1
    end
  end

  def rewards_at_current_page
  	rewards_paginated
  end

  def next_page_index
  	rewards_paginated.next_page.nil? ? 0 : rewards_paginated.next_page
  end

  private

  def member
    @member
  end
  
  def rewards
    @rewards ||= MemberReward.without_deleted.with_all_relations.for_member_id(member.id)
  end

  def rewards_paginated
    rewards.paginate(page: @page_index)
  end
  
end
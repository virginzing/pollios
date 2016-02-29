class Member::RewardList

  attr_reader :member, :index

  def initialize(member, options = {})
    @member = member
    @index = options[:index] || 1
  end

  def rewards_at_current_page
    rewards_paginated
  end

  def next_index
    rewards_paginated.next_page || 0
  end

  private

  def rewards
    @rewards ||= MemberReward.without_deleted.with_all_relations.for_member_id(member.id)
  end

  def rewards_paginated
    rewards.paginate(page: index)
  end
  
end
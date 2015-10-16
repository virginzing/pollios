class Member::RewardList

  def initialize(member, options = {})
    @member = member
  end

  def member
    @member
  end

  def rewards
    @rewards ||= CampaignMember.without_deleted.list_reward(@member)
  end
  
end
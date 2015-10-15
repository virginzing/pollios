class Member::RewardList

  def initialize(member, options = {})
    @member = member
  end

  def member
    @member
  end

  def list_reward
    @rewards = CampaignMember.without_deleted.list_reward(@member)
  end
  
end
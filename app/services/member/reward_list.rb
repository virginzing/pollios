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
  	rewards
  end

  def next_page_index
  	rewards.next_page.nil? ? 0 : rewards.next_page
  end

  private

  def member
    @member
  end

  def rewards
    @rewards ||= CampaignMember.without_deleted.list_reward(member).paginate(page: @page_index)
  end
  
end
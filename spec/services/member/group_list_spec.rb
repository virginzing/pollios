require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupList" do

  context '#member_of?: Is a member in a group in someone point of view.' do
    before(:all) do
      @public_group = FactoryGirl.create(:group, public: true)
      @private_group = FactoryGirl.create(:group)
      @member_1 = FactoryGirl.create(:member_who_joins_groups, groups: [@public_group, @private_group])
      @member_2 = FactoryGirl.create(:member_who_joins_groups, groups: [@private_group])
      @member_3 = FactoryGirl.create(:member)
    end

    it '- When the group is public, any one should see that the member is in the group.' do
      expect(Member::GroupList.new(@member_1).member_of?(@public_group)).to be true
      expect(Member::GroupList.new(@member_1, viewing_member: @member_3).member_of?(@public_group)).to be true
      expect(Member::GroupList.new(@member_1, viewing_member: @member_2).member_of?(@public_group)).to be true
    end

    it '- When the group is private, only the member and member who join the same group can see.' do
      expect(Member::GroupList.new(@member_1).member_of?(@private_group)).to be true
      expect(Member::GroupList.new(@member_1, viewing_member: @member_2).member_of?(@private_group)).to be true
      expect(Member::GroupList.new(@member_1, viewing_member: @member_3).member_of?(@private_group)).to be false
    end
  end

  context '#as_member: List groups which a member joins as member, in someone point of view.' do
    before(:all) do
      @public_groups = FactoryGirl.create_list(:group, 2, public: true)
      @private_groups = FactoryGirl.create_list(:group, 2)
      @member_1 = FactoryGirl.create(:member_who_joins_groups, groups: [@public_groups[0], @private_groups[1]])
      @member_2 = FactoryGirl.create(:member_who_joins_groups, groups: [@private_groups[1]])
      @member_3 = FactoryGirl.create(:member_who_joins_groups, groups: @public_groups)
      @member_4 = FactoryGirl.create(:member)
    end

    it '- When the member view themself, the member should see all the groups they joined.' do
      expect(Member::GroupList.new(@member_1).as_member).to match_array [@public_groups[0], @private_groups[1]]
    end

    it '- When the other member who shares the same private groups is viewing, they should see only private groups they join, and public groups the member joins.' do
      expect(Member::GroupList.new(@member_1, viewing_member: @member_2).as_member).to \
        match_array [@public_groups[0], @private_groups[1]]
      expect(Member::GroupList.new(@member_1, viewing_member: @member_3).as_member).to \
        match_array [@public_groups[0]]
    end

    it "- When the other member who doesn't share any common private group is viewing, they shouldn't see any private group." do
      expect(Member::GroupList.new(@member_1, viewing_member: @member_4).as_member).to \
        match_array [@public_groups[0]]
    end
  end

  context '#as_admin: List groups which a member administrates, in someone point of view.' do
    before(:all) do
      @public_groups = FactoryGirl.create_list(:group, 2, public: true)
      @private_groups = FactoryGirl.create_list(:group, 2)
      @member_1 = FactoryGirl.create(:member_who_joins_groups, groups: [@public_groups[0], @private_groups[1]], is_admin: true)
      @member_2 = FactoryGirl.create(:member_who_joins_groups, groups: [@private_groups[1]])
      @member_3 = FactoryGirl.create(:member_who_joins_groups, groups: @public_groups)
      @member_4 = FactoryGirl.create(:member)
    end

    it '- When the member view themself, the member should see all the groups they administrate.' do
      expect(Member::GroupList.new(@member_1).as_admin).to match_array [@public_groups[0], @private_groups[1]]
    end

    it '- When the other member who share the same private groups is viewing, they should see only private groups they join, and public groups the member joins.' do
      expect(Member::GroupList.new(@member_1, viewing_member: @member_2).as_admin).to \
        match_array [@public_groups[0], @private_groups[1]]
      expect(Member::GroupList.new(@member_1, viewing_member: @member_3).as_admin).to \
        match_array [@public_groups[0]]
    end

    it "- When the other member who doesn't share any common private group is viewing, they shouldn't see any private group." do
      expect(Member::GroupList.new(@member_1, viewing_member: @member_4).as_admin).to \
        match_array [@public_groups[0]]
    end
  end

end

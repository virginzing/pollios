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
      @member_1 = FactoryGirl.create(:member_who_joins_groups, groups: [@public_groups[0]] + @private_groups)
      @member_2 = FactoryGirl.create(:member_who_joins_groups, groups: [@private_groups[1]])
      @member_3 = FactoryGirl.create(:member_who_joins_groups, groups: @public_groups)
      @member_4 = FactoryGirl.create(:member)
    end

    it '- When the member view themself, the member should see all the groups they joined.' do
      expect(Member::GroupList.new(@member_1).as_member).to match_array [@public_groups[0]] + @private_groups
    end

    it '- The other should see only the common private groups, and the public groups the member joined.' do
      expect(Member::GroupList.new(@member_1, viewing_member: @member_2).as_member)
        .to match_array [@public_groups[0], @private_groups[1]]
      expect(Member::GroupList.new(@member_1, viewing_member: @member_3).as_member)
        .to match_array [@public_groups[0]]
    end

  end

  context '#as_admin: List groups which a member administrates, in someone point of view.' do
    before(:all) do
      @public_groups = FactoryGirl.create_list(:group, 2, public: true)
      @private_groups = FactoryGirl.create_list(:group, 2)
      @member_1 = FactoryGirl.create(:member_who_joins_groups, groups: [@public_groups[0]] + @private_groups, is_admin: true)
      @member_2 = FactoryGirl.create(:member_who_joins_groups, groups: [@private_groups[1]])
      @member_3 = FactoryGirl.create(:member_who_joins_groups, groups: @public_groups)
      @member_4 = FactoryGirl.create(:member)
    end

    it '- When the member view themself, the member should see all the groups they administrate.' do
      expect(Member::GroupList.new(@member_1).as_admin).to match_array [@public_groups[0]] + @private_groups
    end

    #
    it '- The other should see only the common private groups, and the public groups the member administrates.' do
      expect(Member::GroupList.new(@member_1, viewing_member: @member_2).as_admin)
        .to match_array [@public_groups[0], @private_groups[1]]
      expect(Member::GroupList.new(@member_1, viewing_member: @member_3).as_admin)
        .to match_array [@public_groups[0]]
    end

  end

  context '#as_admin_with_requests: List groups which a member administrates, and have requests sent to the group.' do
    before(:all) do
      @public_groups = FactoryGirl.create_list(:group, 2, public: true)
      @private_groups = FactoryGirl.create_list(:group, 2)
      @member_1 = FactoryGirl.create(:member_who_joins_groups, groups: @public_groups + @private_groups, is_admin: true)
      @member_2 = FactoryGirl.create(:member_who_joins_groups, groups: [@private_groups[1]])
      @member_3 = FactoryGirl.create(:member_who_joins_groups, groups: @public_groups)
      FactoryGirl.create(:member_who_sends_join_requests, groups: [@public_groups[1], @private_groups[1]])
    end

    it '- When the member view themself, the member should see all the groups which they administrate, and have requests.' do
      expect(Member::GroupList.new(@member_1).as_admin_with_requests).to match_array [@public_groups[1], @private_groups[1]]
    end

    it '- The other should see only the common private groups, and the public groups the member is admin and have requests.' do
      expect(Member::GroupList.new(@member_1, viewing_member: @member_2).as_admin_with_requests)
        .to match_array [@public_groups[1], @private_groups[1]]
      expect(Member::GroupList.new(@member_1, viewing_member: @member_3).as_admin_with_requests)
        .to match_array [@public_groups[1]]
    end
  end

  context '#requesting_to_join: List groups which a member sent join request to groups.' do
    before(:all) do
      @public_groups = FactoryGirl.create_list(:group, 2, public: true)
      @private_groups = FactoryGirl.create_list(:group, 2)
      @member_1 = FactoryGirl.create(:member_who_sends_join_requests, groups: [@public_groups[0], @private_groups[0]])
      @member_2 = FactoryGirl.create(:member)
    end

    it "- Anyone can see a member's requesting to join groups." do
      expect(Member::GroupList.new(@member_1, veiwing_member: @member_2).requesting_to_joins)
        .to match_array [@public_groups[0], @private_groups[0]]
    end

  end

end

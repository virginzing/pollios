require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupList" do

  context '#member_of?: Is a member in a private group in someone point of view.' do
    before(:context) do
      @group = FactoryGirl.create(:member_created_group, :with_members)
      @group_admin = Group::MemberList.new(@group).admins[0]
      @group_members = Group::MemberList.new(@group).members
      @outsider = FactoryGirl.create(:member)
    end

    it '- When the member is ordinary member, the insider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @group_members[2]).member_of?(@group)).to be true
    end

    it '- When the member is admin, the insider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_admin, viewing_member: @group_members[2]).member_of?(@group)).to be true
    end

    it '- When the member is ordinary member, the outsider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @outsider).member_of?(@group)).to be false
    end

    it '- When the member is admin, the outsider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_admin, viewing_member: @outsider).member_of?(@group)).to be false
    end
  end

  context '#member_of?: Is a member in a public group in someone point of view.' do
    before(:context) do
      @group = FactoryGirl.create(:member_created_group, :with_members, public: true)
      @group_admin = Group::MemberList.new(@group).admins[0]
      @group_members = Group::MemberList.new(@group).members
      @outsider = FactoryGirl.create(:member)
    end

    it '- When the member is ordinary member, the outsider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @outsider).member_of?(@group)).to be true
    end

    it '- When the member is admin, the outsider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_admin, viewing_member: @outsider).member_of?(@group)).to be true
    end

    it '- When the member is ordinary member, the insider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @group_members[2]).member_of?(@group)).to be true
    end

    it '- When the member is admin, the insider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_admin, viewing_member: @group_members[2]).member_of?(@group)).to be true
    end

  end


end

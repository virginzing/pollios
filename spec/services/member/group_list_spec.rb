require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupList" do

  before(:example) do
    @group = FactoryGirl.create(:group, :with_4_members)
    @group_admin = Group::MemberList.new(@group).admins[0]
    @group_members = Group::MemberList.new(@group).members
    @outsider = FactoryGirl.create(:member)
  end

  context '#member_of?: Is a member is in a group(not public) in insider(who is in the group) point of view.' do
    it '- When the member is ordinary member, the insider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @group_members[3]).member_of?(@group)).to be true
    end

    it '- When the member is admin, the insider should see that the member is in the group.' do
      Member::GroupAdminAction.new(@group_admin, @group, @group_members[1]).promote
      expect(@group.group_members.detect { |m| m.member_id = @group_members[1].id }.is_master).to be true
      expect(Member::GroupList.new(@group_members[1], viewing_member: @group_members[3]).member_of?(@group)).to be true
    end
  end

  context '#member_of?: Is a member is in a group(not public) in outsider(who is not in the group) point of view.' do
    it '- When the member is ordinary member, the outsider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @outsider).member_of?(@group)).to be false
    end

    it '- When the member is admin, the outsider should see that the member is in the group.' do
      Member::GroupAdminAction.new(@group_admin, @group, @group_members[1]).promote
      expect(@group.group_members.detect { |m| m.member_id = @group_members[1].id }.is_master).to be true
      expect(Member::GroupList.new(@group_members[1], viewing_member: @outsider).member_of?(@group)).to be false
    end
  end

  context '#member_of?: Is a member is an a public group in outsider(who is not in the group) point of view.' do
    before(:each) do
      @group.update!(public: true)
    end

    it '- When the member is ordinary member, the outsider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @outsider).member_of?(@group)).to be true
    end

    it '- When the member is admin, the outsider should see that the member is in the group.' do
      Member::GroupAdminAction.new(@group_admin, @group, @group_members[1]).promote
      expect(@group.group_members.detect { |m| m.member_id = @group_members[1].id }.is_master).to be true
      expect(Member::GroupList.new(@group_members[1], viewing_member: @outsider).member_of?(@group)).to be true
    end
  end

  context '#member_of?: Is a member is an a public group in insider(who is in the group) point of view.' do
    before(:each) do
      @group.update!(public: true)
    end

    it '- When the member is ordinary member, the insider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @group_members[3]).member_of?(@group)).to be true
    end

    it '- When the member is admin, the insider should see that the member is in the group.' do
      Member::GroupAdminAction.new(@group_admin, @group, @group_members[1]).promote
      expect(@group.group_members.detect { |m| m.member_id = @group_members[1].id }.is_master).to be true
      expect(Member::GroupList.new(@group_members[1], viewing_member: @group_members[3]).member_of?(@group)).to be true
    end
  end

  

end

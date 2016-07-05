require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupList" do

  before(:example) do
    @group = FactoryGirl.create(:member_created_group, :with_members)
    @group_admin = Group::MemberList.new(@group).admins[0]
    @group_members = Group::MemberList.new(@group).members
    @outsider = FactoryGirl.create(:member)
  end

  context '#member_of?: Is a member in a group(not public) in insider(who is in the group) point of view.' do
    it '- When the member is ordinary member, the insider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @group_members[2]).member_of?(@group)).to be true
    end

    it '- When the member is admin, the insider should see that the member is in the group.' do
      @group.group_members.detect { |m| m.member_id == @group_members[1].id }.update!(is_master: true)
      expect(Member::GroupList.new(@group_members[1], viewing_member: @group_members[2]).member_of?(@group)).to be true
    end
  end

  context '#member_of?: Is a member in a group(not public) in outsider(who is not in the group) point of view.' do
    it '- When the member is ordinary member, the outsider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @outsider).member_of?(@group)).to be false
    end

    it '- When the member is admin, the outsider should see that the member is in the group.' do
      @group.group_members.detect { |m| m.member_id == @group_members[1].id }.update!(is_master: true)
      expect(Member::GroupList.new(@group_members[1], viewing_member: @outsider).member_of?(@group)).to be false
    end
  end

  context '#member_of?: Is a member a public group in outsider(who is not in the group) point of view.' do
    before(:each) do
      @group.update!(public: true)
    end

    it '- When the member is ordinary member, the outsider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @outsider).member_of?(@group)).to be true
    end

    it '- When the member is admin, the outsider should see that the member is in the group.' do
      @group.group_members.detect { |m| m.member_id == @group_members[1].id }.update!(is_master: true)
      expect(Member::GroupList.new(@group_members[1], viewing_member: @outsider).member_of?(@group)).to be true
    end
  end

  context '#member_of?: Is a member a public group in insider(who is in the group) point of view.' do
    before(:each) do
      @group.update!(public: true)
    end

    it '- When the member is ordinary member, the insider should see that the member is in the group.' do
      expect(Member::GroupList.new(@group_members[0], viewing_member: @group_members[2]).member_of?(@group)).to be true
    end

    it '- When the member is admin, the insider should see that the member is in the group.' do
      @group.group_members.detect { |m| m.member_id == @group_members[1].id }.update!(is_master: true)
      expect(Member::GroupList.new(@group_members[1], viewing_member: @group_members[2]).member_of?(@group)).to be true
    end
  end

end

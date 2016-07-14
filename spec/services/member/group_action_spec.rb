require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupAction" do

  before(:context) do
    @group_admin = FactoryGirl.create(:member)
    @a_member = FactoryGirl.create(:member)
  end

  context '#create: A member create group, became admin of the group.' do
    before(:all) do
      @new_group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group))
    end

    it '- A member could create a group' do
      expect(@new_group).to be_valid
    end

    it '- A member is an admin of the created group' do
      expect(Group::MemberList.new(@new_group).admin?(@group_admin)).to be true
    end

    it '- A member does not upload cover photo, should be set between 1-26' do
      expect(@new_group.cover_preset.to_i).to be_between(1, 26).inclusive
    end

    it '- Group setting default is need approve' do
      expect(@new_group.need_approve).to be true
    end

    it '- Group-Company not got created' do
      expect(@new_group.group_company).to be nil
    end
  end

  context '#create: A member create group with cover url.' do
    before(:all) do
      @new_group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group_with_cover_url))
    end

    it '- A cover URL is given and set to group' do
      expect(@new_group.cover.url).to include('v1436275533/mkhzo71kca62y9btz3bd.png')
    end

    it '- A cover preset is 0 (no-preset)' do
      expect(@new_group.cover_preset.to_i).to eq(0)
    end
  end

  context '#create #invite: A member create group with invitation friend ids.' do
    before(:all) do
      @friends = FactoryGirl.create_list(:member, 5)
      @friend_ids = @friends.map(&:id)
      @new_group = Member::GroupAction.new(@group_admin).create(
        FactoryGirl.attributes_for(:group_with_invitation_friend_ids, friend_ids: @friend_ids))
    end

    it '- 5 members are pending in group.' do
      expect(Group::MemberList.new(@new_group).pending.size).to eq(5)
    end

    it '- If the first two member are already member in group, then the last three are pending.' do
      @new_group.group_members.where(member_id: @friend_ids[0..1]).each { |m| m.update(active: true) }
      expect(Group::MemberList.new(@new_group).pending.map(&:id)).to match_array @friend_ids[2..4]
    end
  end

  context '#join: A member request to join group that need approve.' do
    before(:all) do
      @group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group))
    end

    it '- A member is requesting in group' do
      expect(Member::GroupAction.new(@a_member, @group).join).to eq group: @group, status: :requesting
      expect(@group.members_request.count).to eq 1
      expect(Group::MemberList.new(@group).requesting).to match_array [@a_member]
    end
  end

  context '#join: A member request to join group that need approve and being invited by admin.' do
    before(:all) do
      @group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group))
      Member::GroupAction.new(@group_admin, @group).invite([@a_member.id])
    end

    it '- A member being invited by admin.' do
      expect(Group::MemberList.new(@group).pending).to include(@a_member)
      expect(@group.group_members.find_by(member_id: @a_member.id).invite_id).to eq @group_admin.id
    end

    it '- A member is member in group.' do
      expect(Member::GroupAction.new(@a_member, @group).join).to eq group: @group, status: :member
      expect(@group.members.count).to eq 2
      expect(Group::MemberList.new(@group).members).to include(@a_member)
    end
  end

  context "#join: A member request to join group that doesn't need approve." do
    before(:all) do
      @group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group))
      @group.update!(need_approve: false)
    end

    it '- A member is member in group' do
      expect(Member::GroupAction.new(@a_member, @group).join).to eq group: @group, status: :member
      expect(@group.members.count).to eq 2
      expect(Group::MemberList.new(@group).members).to include(@a_member)
    end
  end

  context '#invite: A member invite friends to group' do
    before(:all) do
      @group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group))
      @friends = FactoryGirl.create_list(:member, 5)
      @friend_ids = @friends.map(&:id)

      Member::GroupAction.new(@group_admin, @group).invite(@friend_ids)
    end

    it '- 5 members are pending in group.' do
      expect(Group::MemberList.new(@group).pending.map(&:id)).to match_array @friend_ids
    end

    it '- The first two members are already member in group and the last three members are pending in group.' do
      @group.group_members.where(member_id: @friend_ids[0..1]).each { |m| m.update(active: true) }
      expect(Group::MemberList.new(@group).pending.map(&:id)).to match_array @friend_ids[2..4]
    end
  end

end

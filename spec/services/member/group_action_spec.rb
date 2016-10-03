require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupAction" do

  before(:context) do
    @member = FactoryGirl.create(:member)
  end

  context '#create: A member create group, became admin of the group.' do
    before(:all) do
      @group = Member::GroupAction.new(@member).create(FactoryGirl.attributes_for(:group))
    end

    it '- A member could create a group' do
      expect(@group).to be_valid
    end

    it '- A member is an admin of the created group' do
      expect(Group::MemberInquiry.new(@group).admin?(@member)).to be true
    end

    it '- A member does not upload cover photo, should be set between 1-26' do
      expect(@group.cover_preset.to_i).to be_between(1, 26).inclusive
    end

    it '- Group setting default is need approve' do
      expect(@group.need_approve).to be true
    end

    it '- Group-Company not got created' do
      expect(@group.group_company).to be nil
    end
  end

  context '#create: A member create group with cover url.' do
    before(:all) do
      @group = Member::GroupAction.new(@member).create(FactoryGirl.attributes_for(:group_with_cover_url))
    end

    it '- A cover URL is given and set to group' do
      expect(@group.cover.url).to include('v1436275533/mkhzo71kca62y9btz3bd.png')
    end

    it '- A cover preset is 0 (no-preset)' do
      expect(@group.cover_preset.to_i).to eq(0)
    end
  end

  context '#create #invite: A member create group with invitation friend ids.' do
    before(:all) do
      @friends = FactoryGirl.create_list(:member, 5)
      @friend_ids = @friends.map(&:id)
      @group = Member::GroupAction.new(@member).create(
        FactoryGirl.attributes_for(:group).merge(friend_ids: @friend_ids)
      )
    end

    it '- 5 members are pending in group.' do
      expect(Group::MemberList.new(@group).pending.size).to eq(5)
    end

    it '- If the first two member are already member in group, then the last three are pending.' do
      @group.group_members.where(member_id: @friend_ids[0..1]).each { |m| m.update(active: true) }
      expect(Group::MemberList.new(@group).pending.map(&:id)).to match_array @friend_ids[2..4]
    end
  end

  context '#join: A member request to join group that need approve.' do
    before(:all) do
      @group = FactoryGirl.create(:group)
    end

    it '- A member is requesting in group' do
      expect(Member::GroupAction.new(@member, @group).join).to eq group: @group, status: :requesting
      expect(@group.members_request.count).to eq 1
      expect(Group::MemberList.new(@group).requesting).to match_array [@member]
    end
  end

  context '#join: A member request to join group that need approve and being invited by admin.' do
    before(:all) do
      @group = FactoryGirl.create(:group)
      @group_admin = Group::MemberList.new(@group).admins.sample

      Member::GroupAction.new(@group_admin, @group).invite([@member.id])
    end

    it '- A member being invited by admin.' do
      expect(Group::MemberList.new(@group).pending).to include(@member)
      expect(@group.group_members.find_by(member_id: @member.id).invite_id).to eq @group_admin.id
    end

    it '- A member is member in group.' do
      expect(Member::GroupAction.new(@member, @group).join).to eq group: @group, status: :member
      expect(@group.members.count).to eq 2
      expect(Group::MemberList.new(@group).members).to include(@member)
    end
  end

  context "#join: A member request to join group that doesn't need approve." do
    before(:all) do
      @group = FactoryGirl.create(:group, :no_need_approve)
    end

    it '- A member is member in group' do
      expect(Member::GroupAction.new(@member, @group).join).to eq group: @group, status: :member
      expect(@group.members.count).to eq 2
      expect(Group::MemberList.new(@group).members).to include(@member)
    end
  end

  context '#invite: A member invite friends to group' do
    before(:all) do
      @group = FactoryGirl.create(:group)
      @group_admin = Group::MemberList.new(@group).admins.sample

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

  context '#leave: A member is leaving a group.' do
    before(:each) do
      @group = FactoryGirl.create(:group)
      FactoryGirl.create(:group_member, group: @group, member: @member)
    end

    it '- The member is in the group, but they are leaving' do
      expect(Group::MemberList.new(@group).members.map(&:id)).to match_array [@member.id]
      expect(Member::GroupAction.new(@member, @group).leave).to eq(@group)
      expect(@group.group_members.map(&:id)).not_to include(@member.id)
    end

    it '- The admin is leaving a group.' do
      @group.group_members.find_by(member_id: @member.id).update(is_master: true)
      expect(Group::MemberList.new(@group).admins).to include(@member)
      expect(Member::GroupAction.new(@member, @group).leave).to eq(@group)
    end
  end

  context '#leave: A member is trying to leave a group, but get an error.' do
    before(:all) do
      @group_admin = FactoryGirl.create(:member)
    end

    xit '- The member is the only group admin.' do
      # TODO: implement this example when there is the guard for this
    end

    it '- The member is not in the group.' do
      @group = FactoryGirl.create(:group)
      expect { Member::GroupAction.new(@member, @group).leave }
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAction.member_is_not_in_group(@group))
    end

    it '- The member is leaving a company group.' do
      @company = FactoryGirl.create(:company_admin, member: @group_admin)
      @company_group = CreateGroupCompany.new(
        @group_admin,
        @company,
        FactoryGirl.attributes_for(:group),
        "#{@member.id}").create_group
      expect { Member::GroupAction.new(@member, @company_group).leave }.to raise_error(
        ExceptionHandler::UnprocessableEntity,
        GuardMessage::GroupAction.cannot_leave_company_group(@company_group))
    end
  end

end

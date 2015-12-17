require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupAction" do
  let(:group_admin) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:a_member) { FactoryGirl.create(:member, email: Faker::Internet.email) }

  context '#create: A member create group, becaming admin of the group' do

    let(:new_group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group)) }

    it '- A member could create a group' do
      expect(new_group).to be_valid
    end

    it '- A member is an admin of the created group' do
      expect(Group::MemberList.new(new_group).admin?(group_admin)).to be true
    end

    it '- A member does not upload cover photo, should be set between 1-26' do 
      expect(new_group.cover_preset.to_i).to be_between(1, 26).inclusive
    end

    it '- Group setting default is need approve' do
      expect(new_group.need_approve).to be true
    end

    it '- Group-Company not got created' do
      expect(new_group.group_company).to be nil
    end
  end

  context '#create: A member create group with cover url' do

    let(:new_group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group_with_cover_url)) }

    it '- A cover URL is given and set to group' do
      expect(new_group.cover.url).to include('v1436275533/mkhzo71kca62y9btz3bd.png')
    end

    it '- A cover preset is 0 (no-preset)' do
      expect(new_group.cover_preset.to_i).to eq(0)
    end
  end

  context '#create #invite: A member create group with invitation friend ids' do

    let(:new_group) do
      Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group_with_invitation_friend_ids))
    end

    before(:context) do
      FactoryGirl.create_list(:sequence_member, 10)
    end

    it '- Members id: 103,104,105,107,108,109 are pending in group' do
      expect(Group::MemberList.new(new_group).pending.map(&:id)).to match_array([103, 104, 105, 107, 108, 109])
    end

    it '- Members id: 108,109 are already member in group and Members id: 103,104,105,107 are pending in group' do
      new_group.group_members.find_by(member_id: 108).update(active: true)
      new_group.group_members.find_by(member_id: 109).update(active: true)

      expect(Group::MemberList.new(new_group).pending.map(&:id)).to match_array([103, 104, 105, 107])
    end
  end

  context '#join: A member request to join group that need approve' do

    let(:group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group)) }
    let(:group_action) { Member::GroupAction.new(a_member, group) }

    it '- A member is requesting in group' do
      expect(group_action.join).to eq group: group, status: :requesting
      expect(group.members_request.count).to eq 1
      expect(Group::MemberList.new(group).requesting).to match_array [a_member]
    end
  end

  context "#join: A member request to join group that doesn't need approve" do

    let(:group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group)) }
    let!(:setting_group_doesnt_need_approve) { group.update!(need_approve: false) }
    let(:group_action) { Member::GroupAction.new(a_member, group) }

    it '- A member is member in group' do
      expect(group_action.join).to eq group: group, status: :member
      expect(group.members.count).to eq 2
      expect(Group::MemberList.new(group).members).to match_array [a_member]
    end
  end

  context '#invite: A member invite friends to group' do

    before(:context) do
      FactoryGirl.create_list(:sequence_member, 10)
    end

    let(:group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group)) }
    let(:group_action) { Member::GroupAction.new(group_admin, group) }
    let!(:invite) { group_action.invite([103, 104, 105, 107, 108, 109]) }

    it '- Members id: 103,104,105,107,108,109 are pending in group' do
      expect(Group::MemberList.new(group).pending.map(&:id)).to match_array([103, 104, 105, 107, 108, 109])
    end

    it '- Members id: 108,109 are already member in group and Members id: 103,104,105,107 are pending in group' do
      group.group_members.find_by(member_id: 108).update(active: true)
      group.group_members.find_by(member_id: 109).update(active: true)

      expect(Group::MemberList.new(group).pending.map(&:id)).to match_array([103, 104, 105, 107])
    end
  end

end
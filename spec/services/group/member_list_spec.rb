require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Group::MemberList" do

  let(:group_admin) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:new_group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group)) }

  let(:new_member1) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:new_member2) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:new_member3) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:new_member4) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:new_member5) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let(:new_member6) { FactoryGirl.create(:member, email: Faker::Internet.email) }

  let(:group_member_inquiry) { Group::MemberInquiry.new(new_group) }

  context 'Including' do

    it '- A member is include group admin or group member ' do
      new_group.group_members.create(member_id: new_member1.id, is_master: false, active: true)

      expect(group_member_inquiry.member_or_admin?(group_admin)).to be true
      expect(group_member_inquiry.member_or_admin?(new_member1)).to be true
    end

    it '- A member is include group admin' do
      expect(group_member_inquiry.admin?(group_admin)).to be true
    end

    it '- A member is include group member' do
      new_group.group_members.create(member_id: new_member1.id, is_master: false, active: true)

      expect(group_member_inquiry.member?(new_member1)).to be true
    end

    it '- A member is include pending member' do
      new_group.group_members.create(member_id: new_member1.id, is_master: false, active: false)

      expect(group_member_inquiry.pending?(new_member1)).to be true
    end

    it '- A member is include requesting member' do
      new_group.request_groups.create(member_id: new_member1.id)
      
      expect(group_member_inquiry.requesting?(new_member1)).to be true
    end

    it "- A member isn't include group" do
      expect(group_member_inquiry.admin?(new_member1)).to be false
      expect(group_member_inquiry.member?(new_member1)).to be false
      expect(group_member_inquiry.pending?(new_member1)).to be false
      expect(group_member_inquiry.requesting?(new_member1)).to be false
    end
  end

  context 'Listing' do
    
    it '- Admins of group' do
      new_group.group_members.create(member_id: new_member1.id, is_master: true, active: true)
      new_group.group_members.create(member_id: new_member2.id, is_master: true, active: true)
      new_group.group_members.create(member_id: new_member3.id, is_master: true, active: true)

      expect(group_member_inquiry.admins).to match_array([group_admin, new_member1, new_member2, new_member3])
    end

    it '- Members of group' do
      new_group.group_members.create(member_id: new_member1.id, is_master: false, active: true)
      new_group.group_members.create(member_id: new_member2.id, is_master: false, active: true)
      new_group.group_members.create(member_id: new_member3.id, is_master: false, active: true)
      new_group.group_members.create(member_id: new_member4.id, is_master: false, active: true)

      expect(group_member_inquiry.members).to match_array([new_member1, new_member2, new_member3, new_member4])
    end

    it '- Pending members of group' do
      new_group.group_members.create(member_id: new_member1.id, is_master: false, active: false)
      new_group.group_members.create(member_id: new_member2.id, is_master: false, active: false)
      new_group.group_members.create(member_id: new_member3.id, is_master: false, active: false)
      new_group.group_members.create(member_id: new_member4.id, is_master: false, active: false)

      expect(group_member_inquiry.pending).to match_array([new_member1, new_member2, new_member3, new_member4])
    end

    it '- Requesting members of group' do
      new_group.request_groups.create(member_id: new_member1.id)
      new_group.request_groups.create(member_id: new_member2.id)
      new_group.request_groups.create(member_id: new_member3.id)
      new_group.request_groups.create(member_id: new_member4.id)

      expect(group_member_inquiry.requesting).to match_array([new_member1, new_member2, new_member3, new_member4])
    end

    it '- Members join requestly' do
      new_group.group_members.create(member_id: new_member1.id, is_master: false, active: true)
      new_group.group_members.create(member_id: new_member2.id, is_master: false, active: true)
      new_group.group_members.create(member_id: new_member3.id, is_master: false, active: true)
      new_group.group_members.create(member_id: new_member4.id, is_master: false, active: true)
      new_group.group_members.create(member_id: new_member5.id, is_master: false, active: true)
      new_group.group_members.create(member_id: new_member6.id, is_master: false, active: true)

      expect(group_member_inquiry.join_recently)
        .to match_array([new_member2, new_member3, new_member4, new_member5, new_member6])
    end
  end

  context 'Filtering' do

    it '- Member ids in group from list of member id' do
      new_group.group_members.create(member_id: new_member1.id, is_master: false, active: true)
      new_group.group_members.create(member_id: new_member2.id, is_master: false, active: true)

      expect(group_member_inquiry.filter_members_from_list([new_member1.id, new_member2.id, new_member3.id]))
        .to match_array([new_member1.id, new_member2.id])
    end

    it '- Member ids not in group from list of member id' do
      new_group.group_members.create(member_id: new_member1.id, is_master: false, active: true)
      new_group.group_members.create(member_id: new_member2.id, is_master: false, active: true)

      expect(group_member_inquiry.filter_non_members_from_list([new_member1.id, new_member2.id, new_member3.id]))
        .to match_array([new_member3.id])
    end
  end

end
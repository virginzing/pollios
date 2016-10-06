require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Group::InquiryList" do

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

  context '#sole_admin?:' do
    context 'Given a group with some members,' do
      before(:all) do
        @group = create(:group_with_members)
      end

      specify 'sole_admin? return true for all group admins.' do
        @group_admins = Group::MemberList.new(@group).admins

        expect(@group_admins.map { |group_admin| Group::MemberInquiry.new(@group).sole_admin?(group_admin) })
          .to all be true
      end

      context 'sole_admin? return false for' do
        specify 'nil.' do
          expect(Group::MemberInquiry.new(@group).sole_admin?(nil)).to be false
        end

        specify 'member not in group.' do
          @member = create(:member)

          expect(Group::MemberInquiry.new(@group).sole_admin?(@member)).to be false
        end

        specify 'all members in group.' do
          @group_members = Group::MemberList.new(@group).members

          expect(@group_members.map { |group_member| Group::MemberInquiry.new(@group).sole_admin?(group_member) })
            .to all be false
        end
      end

      context 'given some additional admins to group,' do
        before(:all) do
          create_list(:group_member, 3, :admin, group: @group)
        end

        specify 'sole_admin? return false for all group admins.' do
          @group_admins = Group::MemberList.new(@group).admins

          expect(@group_admins.map { |group_admin| Group::MemberInquiry.new(@group).sole_admin?(group_admin) })
            .to all be false
        end
      end

    end
  end

end

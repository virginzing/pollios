require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupAdminAction" do
  let!(:group_admin) { FactoryGirl.create(:member, email: Faker::Internet.email) }
  let!(:member_one) { FactoryGirl. create(:member, email: Faker::Internet.email, fullname: 'Member One') }

  context '#approve: A group admin approve a join-request' do
    let(:need_approve_group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve)) }
    let(:admin_group_action) { Member::GroupAction.new(group_admin, need_approve_group) }
    let(:one_group_action) { Member::GroupAction.new(member_one, need_approve_group) }
    let(:group_admin_action_on_one) { Member::GroupAdminAction.new(group_admin, need_approve_group, member_one) }

    it 'A member request to join the group and admin approve' do
      one_group_action.join
      group_admin_action_on_one.approve
      expect(Group::MemberList.new(need_approve_group).members.map(&:id)).to match_array [member_one.id]
    end
  end

end

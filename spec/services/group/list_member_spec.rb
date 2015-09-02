require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Group::ListMember" do

	context "A member is" do

		let(:group_admin) { FactoryGirl.create(:group_member_that_is_admin) }
		let(:group_member) { FactoryGirl.create(:group_member_that_is_member) }
		let(:member_active) { FactoryGirl.create(:group_member_that_is_active) }
		let(:member_pending) { FactoryGirl.create(:group_member_that_is_pending) }

		it "- admin" do
			expect(group_admin.is_master).to be true
		end

		it "- member" do
			expect(group_member.is_master).to be false
		end

		it "- active" do
			expect(member_active.active).to be true
		end

		it "- pending" do
			expect(member_pending.active).to be false
		end

	end

	context "Filter" do

		let(:group_admin) {create(:member, fullname: "Admin") }
		let(:group) { Member::GroupService.new(group_admin).create(FactoryGirl.attributes_for(:group_with_invitation_list)) }
		#(:new_group) { Member::GroupService.new(group_admin).create(FactoryGirl.attributes_for(:group_member_with_member_list)) }

		it "- members id: 103,104,105,106,107,108,109 are non member form list" do			
			expect(Group::ListMember.new(group).filter_non_members_from_list([103, 104, 105, 107, 108, 109])).to match_array([103, 104, 105, 107, 108, 109])
		end
	end

end
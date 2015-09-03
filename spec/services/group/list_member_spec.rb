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

		let(:group_admin) { create(:member, id: 100) }
		let(:new_group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group)) }

		let!(:group_member) { create(:group_member, member_id: 103, group_id: 1) }
		let!(:group_member_2) { create(:group_member, member_id: 109, group_id: 1) }

		it "- members id: 104,105,107,108 are non members from list" do	
			expect(Group::ListMember.new(new_group).filter_non_members_from_list([100, 103, 104, 105, 107, 108, 109])).to match_array([104, 105, 107, 108])
        end

        it "- members id: 100 is members from list" do
        	expect(Group::ListMember.new(new_group).filter_members_from_list([100, 103, 104, 105, 107, 108, 109])).to match_array([])
        end
	end

end
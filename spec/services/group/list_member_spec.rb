require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Group::ListMember" do

	let(:group_admin) { FactoryGirl.create(:group_member_that_is_admin) }

	context "A member is" do

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

		let(:new_group) { Member::GroupService.new(group_admin).create(FactoryGirl.attributes_for(:member_list))}

	end

end
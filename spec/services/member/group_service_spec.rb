require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupService" do

    let(:group_admin) { create(:member, fullname: "GroupAdmin Member") }
    let(:group_member) { create(:member, fullname: "Ordinary GroupMember") }
    let(:invitee_member) { create(:member, fullname: "GroupOutsider Member") }

    context "A member create group, becoming admin of the group" do

        let(:new_group) { Member::GroupService.new(group_admin).create(FactoryGirl.attributes_for(:group)) }

        it "- A member could create a group" do
            expect(new_group).to be_truthy
        end

        it "- A member is an admin of the created group" do
            expect(Group::Service.new(new_group).is_admin_of_group?(group_admin.id)).to be true
        end

        it "- A member does not upload cover photo, should be set between 1-26" do 
            expect(new_group.cover_preset.to_i).to be_between(1, 26).inclusive
        end

        it "- Group-Company not got created" do
            expect(new_group.group_company).to be_falsey
        end
    end

    context "A member create group with cover url" do
        let(:new_group) { Member::GroupService.new(group_admin).create(FactoryGirl.attributes_for(:group_with_cover_url)) }

        it "- A cover URL is given and set to group" do
            expect(new_group.cover.url).to include("v1436275533/mkhzo71kca62y9btz3bd.png")
        end

        it "- A cover preset is 0 (no-preset)" do
            expect(new_group.cover_preset.to_i).to eq(0)
        end
    end

    # TODO: Later, do a proper Company::Group service for this one
    context "A Member who is also a company create a group" do
        let(:company) { create(:member_is_company, fullname: "A PolliosCompany") }
        let(:new_group) { Member::GroupService.new(company).create(FactoryGirl.attributes_for(:group)) }

        it "- Group-Company got created" do
            expect(new_group.group_company).to be_valid
        end
    end
end
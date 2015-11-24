require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupAction" do

    let(:group_admin) { create(:member, fullname: "GroupAdmin Member") }
    let(:group_member) { create(:member, fullname: "Ordinary GroupMember") }
    let(:invitee_member) { create(:member, fullname: "GroupOutsider Member") }

    context "#create: A member create group, becoming admin of the group" do

        let(:new_group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group)) }

        it "- A member could create a group" do
            expect(new_group).to be_truthy
        end

        it "- A member is an admin of the created group" do
            expect(Group::MemberList.new(new_group).admin?(group_admin)).to be true
        end

        it "- A member does not upload cover photo, should be set between 1-26" do 
            expect(new_group.cover_preset.to_i).to be_between(1, 26).inclusive
        end

        it "- Group-Company not got created" do
            expect(new_group.group_company).to be_falsey
        end
    end

    context "#create: A member create group that needs approve" do
        let(:new_group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve)) }

        it "- Group really needs approve" do
            expect(new_group.need_approve).to be true
        end
    end

    context "#create: A member create group that doesn't need approve" do
        let(:new_group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group_that_dont_need_approve)) }

        it "- Group really doesn't need approve" do
            expect(new_group.need_approve).to be false
        end

    end

    context "#create: A member create group with cover url" do
        let(:new_group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group_with_cover_url)) }

        it "- A cover URL is given and set to group" do
            expect(new_group.cover.url).to include("v1436275533/mkhzo71kca62y9btz3bd.png")
        end

        it "- A cover preset is 0 (no-preset)" do
            expect(new_group.cover_preset.to_i).to eq(0)
        end
    end

    # TODO: Later, do a proper Company::Group service for this one
    context "#create: A Member who is a Company create a group" do
        let(:company) { create(:member_is_company, fullname: "A PolliosCompany") }
        let(:new_group) { Member::GroupAction.new(company).create(FactoryGirl.attributes_for(:group)) }

        it "- Group-Company got created" do
            expect(new_group.group_company).to be_valid
        end
    end

    context "#create #invite: A member create group with invitation list: 103,104,105,107,108,109" do
        let(:new_group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group_with_invitation_list)) }

        before(:context) do
            users = FactoryGirl.create_list(:sequence_member, 10)
        end

        it "- Members id: 103,104,105,107,108,109 are not in group" do
            expect(Group::MemberList.new(new_group).filter_non_members_from_list([103, 104, 105, 107, 108, 109])).to match_array([103, 104, 105, 107, 108, 109])
        end

        it "- Group has member id: 103,104,105,107,108,109 in inactive members" do
            expect(Group::MemberList.new(new_group).pending_ids_non_cache).to include(103, 104, 105, 107, 108, 109)
        end
    end


    context "#join: A member request joining group that doesn't need approval" do
        let!(:group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group_that_dont_need_approve)) }
        let!(:group_action) { Member::GroupAction.new(group_admin, group) }

        it "- A member could join group (exist in group-member list)" do
        end
    end

    context "#join: A member request joining group that needs approval" do
        let(:group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve)) }

        it "- A member is in pending approval list" do
        end

        it "- An admin of the group is notified" do
        end
    end


    context "#invite: Admin member invite user to group" do
        let(:group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group)) }

    end

    context "#invite: Non-admin member invite user to group that don't need approve" do
        let(:group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group_that_dont_need_approve)) }

    end

    context "#invite: Non-admin member invite user to group that needs approve" do
        let(:group) { Member::GroupAction.new(group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve)) }

    end

end
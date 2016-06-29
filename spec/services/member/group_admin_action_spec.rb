require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupAdminAction" do

  before(:context) {
    @group_admin = FactoryGirl.create(:member, email: Faker::Internet.email)
    @member = FactoryGirl.create(:member, fullname: 'Member One', email: Faker::Internet.email)
  }

  context '#approve: A need-approve-group admin approves a join request.' do
    before(:context) {
      @need_approve_group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve))
      @admin_group_action = Member::GroupAction.new(@group_admin, @need_approve_group)
      @one_group_action = Member::GroupAction.new(@member, @need_approve_group)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @need_approve_group, @member)
    }

    it '- A group admin approve a join request.' do
      @one_group_action.join
      @group_admin_action_on_one.approve
      expect(Group::MemberList.new(@need_approve_group).members.map(&:id)).to match_array [@member.id]
    end

    it '- A group admin tries to approve a join request but the member is already in the group.' do
      @one_group_action.join
      @group_admin_action_on_one.approve
      expect{ @group_admin_action_on_one.approve }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} is already in #{@need_approve_group.name}.")
    end

    it '- A group admin tries to approve a request that has never been sent to admin.' do
      expect{ @group_admin_action_on_one.approve }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} doesn't sent join request to #{@need_approve_group.name}.")
    end
  end

  context '#deny: A need-approve-group admin deny a join request.' do
    before(:context) {
      @need_approve_group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve))
      @admin_group_action = Member::GroupAction.new(@group_admin, @need_approve_group)
      @one_group_action = Member::GroupAction.new(@member, @need_approve_group)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @need_approve_group, @member)
    }

    it '- A group admin deny a join request.' do
      @one_group_action.join
      @group_admin_action_on_one.deny
      expect(Group::MemberList.new(@need_approve_group).members.size).to eq(0)
      expect(Group::MemberList.new(@need_approve_group).requesting.size).to eq(0)
    end

    it '- A group admin tries to deny a join request but the member is already in the group.' do
      @one_group_action.join
      @group_admin_action_on_one.approve
      expect{ @group_admin_action_on_one.deny }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} is already in #{@need_approve_group.name}.")
    end

    it '- A group admin tries to deny a request that has never been sent to admin.' do
      expect{ @group_admin_action_on_one.deny }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} doesn't have any request to #{@need_approve_group.name}.")
    end
  end

  context '#remove: A group admin remove a member from a group.' do
    before(:context) {
      @need_approve_group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve))
      @one_group_action = Member::GroupAction.new(@member, @need_approve_group)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @need_approve_group, @member)
    }

    it '- A group admin remove a member from the group.' do
      @one_group_action.join
      @group_admin_action_on_one.approve
      @group_admin_action_on_one.remove
      expect(Group::MemberList.new(@need_approve_group).members.map(&:id)).to match_array []
    end

    it '- A group admin tries to remove a member who is not member in the group.' do
      expect{ @group_admin_action_on_one.remove }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} isn't member in #{@need_approve_group.name}.")
    end

    it '- A group admin tries to remove himself.' do
      @group_admin_action_on_self = Member::GroupAdminAction.new(@group_admin, @need_approve_group, @group_admin)
      expect{ @group_admin_action_on_self.remove }. to raise_error(ExceptionHandler::UnprocessableEntity, "You can't remove yourself.")
    end
  end

  context '#promote: A group admin promote a member to be an admin.' do
    before(:context) {
      @group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group))
      @group.update(need_approve: false)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @group, @member)
      @one_group_action = Member::GroupAction.new(@member, @group)
    }

    it '- A group admin promote a member to be an admin.' do
      @one_group_action.join
      @group_admin_action_on_one.promote
      expect(Group::MemberList.new(@group).admins.map(&:id)).to match_array [@group_admin.id, @member.id]
    end

    it '- A group admin should not be able to promote a member who is not in the group.' do
      expect{ @group_admin_action_on_one.promote }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} isn't member in #{@group.name}.")
    end

    it '- A group admin should not be able to promote a member who is a group admin.' do
      @one_group_action.join
      @group_admin_action_on_one.promote
      @one_admin_action_on_group_admin = Member::GroupAdminAction.new(@member, @group, @group_admin)
      expect{ @one_admin_action_on_group_admin.promote }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@group_admin.get_name} is already admin.")
    end
  end

  context '#demote: A group admin demote other admin in a group.' do
    before(:context) {
      @group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group))
      @group.update(need_approve: false)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @group, @member)
      @one_group_action = Member::GroupAction.new(@member, @group)
    }

    it '- A group admin demote other group admin.' do
      @one_group_action.join
      @group_admin_action_on_one.promote
      expect{ @group_admin_action_on_one.demote }.not_to raise_error
      expect(Group::MemberList.new(@group).admins.map(&:id)).to match_array [@group_admin.id]
    end

    it '- A group admin should not be able to demote group creator.' do
      @one_group_action.join
      @group_admin_action_on_one.promote
      @one_admin_action_on_group_admin = Member::GroupAdminAction.new(@member, @group, @group_admin)
      expect{ @one_admin_action_on_group_admin.demote }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@group_admin.get_name} is group creator.")
    end

    it '- A group admin should not be able to demote a member who is not admin.' do
      @one_group_action.join
      expect{ @group_admin_action_on_one.demote }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} isn't admin.")
    end

    it '- A group admin should not be able to demote member who is not in the group.' do
      expect{ @group_admin_action_on_one.demote }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} isn't member in #{@group.name}.")
    end
  end

  context '#promote #remove: A group admin tries to remove group creator from a group.' do
    before(:context) {
      @group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group))
      @group.update(need_approve: false)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @group, @member)
      @one_group_action = Member::GroupAction.new(@member, @group)
    }

    it '- A group admin should not be able to remove group creator from the group.' do
      @one_group_action.join
      @group_admin_action_on_one.promote
      @one_admin_action_on_group_admin = Member::GroupAdminAction.new(@member, @group, @group_admin)
      expect{ @one_admin_action_on_group_admin.remove }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} is group creator.")
    end
  end
end

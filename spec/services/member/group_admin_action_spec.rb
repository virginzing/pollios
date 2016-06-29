require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupAdminAction" do

  before(:context) {
    @group_admin = FactoryGirl.create(:member, email: Faker::Internet.email)
    @member = FactoryGirl.create(:member, fullname: 'Member One', email: Faker::Internet.email)
  }

  context '#approve: A need-approve-group admin approves a join request' do
    before(:context) {
      @need_approve_group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve))
      @admin_group_action = Member::GroupAction.new(@group_admin, @need_approve_group)
      @one_group_action = Member::GroupAction.new(@member, @need_approve_group)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @need_approve_group, @member)
    }

    it 'A group admin approve a join request' do
      @one_group_action.join
      @group_admin_action_on_one.approve
      expect(Group::MemberList.new(@need_approve_group).members.map(&:id)).to match_array [@member.id]
    end

    it 'A group admin tries to approve a join request but the member is already in the group.' do
      @one_group_action.join
      @group_admin_action_on_one.approve
      expect{ @group_admin_action_on_one.approve }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} is already in #{@need_approve_group.name}.")
    end

    it 'A group admin tries to approve a request that has never been sent to admin.' do
      expect{ @group_admin_action_on_one.approve }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} doesn't sent join request to #{@need_approve_group.name}.")
    end
  end

  context '#deny: A need-approve-group admin deny a join request' do
    before(:context) {
      @need_approve_group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve))
      @admin_group_action = Member::GroupAction.new(@group_admin, @need_approve_group)
      @one_group_action = Member::GroupAction.new(@member, @need_approve_group)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @need_approve_group, @member)
    }

    it 'A group admin deny a join request' do
      @one_group_action.join
      @group_admin_action_on_one.deny
      expect(Group::MemberList.new(@need_approve_group).members.size).to eq(0)
      expect(Group::MemberList.new(@need_approve_group).requesting.size).to eq(0)
    end

    it 'A group admin tries to deny a join request but the member is already in the group' do
      @one_group_action.join
      @group_admin_action_on_one.approve
      expect{ @group_admin_action_on_one.deny }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} is already in #{@need_approve_group.name}.")
    end

    it 'A group admin tries to deny a request that has never been sent to admin.' do
      expect{ @group_admin_action_on_one.deny }.to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member.get_name} doesn't have any request to #{@need_approve_group.name}.")
    end
  end

end

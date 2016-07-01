require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupAdminAction" do

  before(:context) do
    @group_admin = FactoryGirl.create(:member)
    @member_1 = FactoryGirl.create(:member, fullname: 'Member One')
  end

  context '#approve: A need-approve-group admin approves a join request.' do
    before(:context) do
      @need_approve_group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve))
      @admin_group_action = Member::GroupAction.new(@group_admin, @need_approve_group)
      @member_1_group_action = Member::GroupAction.new(@member_1, @need_approve_group)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @need_approve_group, @member_1)
    end

    it '- A group admin approve a join request.' do
      @member_1_group_action.join
      expect { @group_admin_action_on_one.approve }.not_to raise_error
      expect(Group::MemberList.new(@need_approve_group).members.map(&:id)).to include @member_1.id
    end

    it '- A group admin should not be able to approve a join request if the member is already in the group.' do
      @member_1_group_action.join
      @group_admin_action_on_one.approve
      expect { @group_admin_action_on_one.approve } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member_1.get_name} is already in #{@need_approve_group.name}.")
    end

    it '- A group admin should not be able to approve a request that has never been sent to admin.' do
      expect { @group_admin_action_on_one.approve } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member_1.get_name} doesn't sent join request to #{@need_approve_group.name}.")
    end
  end

  context '#deny: A need-approve-group admin deny a join request.' do
    before(:context) do
      @need_approve_group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve))
      @admin_group_action = Member::GroupAction.new(@group_admin, @need_approve_group)
      @member_1_group_action = Member::GroupAction.new(@member_1, @need_approve_group)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @need_approve_group, @member_1)
    end

    it '- A group admin deny a join request.' do
      @member_1_group_action.join
      expect { @group_admin_action_on_one.deny }.not_to raise_error
      expect(Group::MemberList.new(@need_approve_group).members.size).to eq(0)
      expect(Group::MemberList.new(@need_approve_group).requesting.size).to eq(0)
    end

    it '- A group admin should not be able to deny a join request if the member is already in the group.' do
      @member_1_group_action.join
      @group_admin_action_on_one.approve
      expect { @group_admin_action_on_one.deny } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member_1.get_name} is already in #{@need_approve_group.name}.")
    end

    it '- A group admin should not be able to deny a request that has never been sent to admin.' do
      expect { @group_admin_action_on_one.deny } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member_1.get_name} doesn't have any request to #{@need_approve_group.name}.")
    end
  end

  context '#remove: A group admin remove a member from a group.' do
    before(:context) do
      @need_approve_group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group_that_need_approve))
      @member_1_group_action = Member::GroupAction.new(@member_1, @need_approve_group)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @need_approve_group, @member_1)
    end

    it '- A group admin remove a member from the group.' do
      @member_1_group_action.join
      @group_admin_action_on_one.approve
      expect { @group_admin_action_on_one.remove }.not_to raise_error
      expect(Group::MemberList.new(@need_approve_group).members.map(&:id)).to match_array []
    end

    it '- A group admin should not be able to remove a member who is not member in the group.' do
      expect { @group_admin_action_on_one.remove } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member_1.get_name} isn't member in #{@need_approve_group.name}.")
    end

    it '- A group admin should not be able to remove himself.' do
      @group_admin_action_on_self = Member::GroupAdminAction.new(@group_admin, @need_approve_group, @group_admin)
      expect { @group_admin_action_on_self.remove } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "You can't remove yourself.")
    end
  end

  context '#promote: A group admin promote a member to be an admin.' do
    before(:context) do
      @group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group))
      @group.update(need_approve: false)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @group, @member_1)
      @member_1_group_action = Member::GroupAction.new(@member_1, @group)
    end

    it '- A group admin promote a member to be an admin.' do
      @member_1_group_action.join
      expect { @group_admin_action_on_one.promote }.not_to raise_error
      expect(Group::MemberList.new(@group).admins.map(&:id)).to include @member_1.id
    end

    it '- A group admin should not be able to promote a member who is not in the group.' do
      expect { @group_admin_action_on_one.promote } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member_1.get_name} isn't member in #{@group.name}.")
    end

    it '- A group admin should not be able to promote a member who is a group admin.' do
      @member_1_group_action.join
      @group_admin_action_on_one.promote
      @member_1_admin_action_on_group_admin = Member::GroupAdminAction.new(@member_1, @group, @group_admin)
      expect { @member_1_admin_action_on_group_admin.promote } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "#{@group_admin.get_name} is already admin.")
    end
  end

  context '#demote: A group admin demote other admin in a group.' do
    before(:context) do
      @group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group))
      @group.update(need_approve: false)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @group, @member_1)
      @member_1_group_action = Member::GroupAction.new(@member_1, @group)
    end

    it '- A group admin demote other group admin.' do
      @member_1_group_action.join
      @group_admin_action_on_one.promote
      expect { @group_admin_action_on_one.demote }.not_to raise_error
      expect(Group::MemberList.new(@group).admins.map(&:id)).to include @group_admin.id
    end

    it '- A group admin should not be able to demote group creator.' do
      @member_1_group_action.join
      @group_admin_action_on_one.promote
      @member_1_admin_action_on_group_admin = Member::GroupAdminAction.new(@member_1, @group, @group_admin)
      expect { @member_1_admin_action_on_group_admin.demote } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "#{@group_admin.get_name} is group creator.")
    end

    it '- A group admin should not be able to demote a member who is not admin.' do
      @member_1_group_action.join
      expect { @group_admin_action_on_one.demote } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member_1.get_name} isn't admin.")
    end

    it '- A group admin should not be able to demote member who is not in the group.' do
      expect { @group_admin_action_on_one.demote }\
        .to raise_error(ExceptionHandler::UnprocessableEntity, "#{@member_1.get_name} isn't member in #{@group.name}.")
    end
  end

  context '#promote #remove: A group admin tries to remove group creator from a group.' do
    before(:context) do
      @group = Member::GroupAction.new(@group_admin).create(FactoryGirl.attributes_for(:group))
      @group.update(need_approve: false)
      @group_admin_action_on_one = Member::GroupAdminAction.new(@group_admin, @group, @member_1)
      @member_1_group_action = Member::GroupAction.new(@member_1, @group)
    end

    it '- A group admin should not be able to remove group creator from the group.' do
      @member_1_group_action.join
      @group_admin_action_on_one.promote
      @member_1_admin_action_on_group_admin = Member::GroupAdminAction.new(@member_1, @group, @group_admin)
      expect { @member_1_admin_action_on_group_admin.remove } \
        .to raise_error(ExceptionHandler::UnprocessableEntity, "#{@group_admin.get_name} is group creator.")
    end
  end
end

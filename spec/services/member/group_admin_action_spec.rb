require 'rails_helper'
require 'guard_message'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Member::GroupAdminAction" do

  before(:context) do
    @group_admin = FactoryGirl.create(:member)
    @member = FactoryGirl.create(:member)
  end

  context '#approve: A group admin approves a join request.' do
    before(:context) do
      @group = FactoryGirl.create(:group, creator: @group_admin)
    end

    it '- A group admin approve a join request.' do
      Member::GroupAction.new(@member, @group).join
      Member::GroupAdminAction.new(@group_admin, @group, @member).approve

      expect(Group::MemberList.new(@group).members.map(&:id)).to include @member.id
    end
  end

  context '#approve: A group admin tries to approves a join request but get an error.' do
    before(:context) do
      @group = FactoryGirl.create(:group, creator: @group_admin)
    end

    it '- A group admin should not be able to approve a join request if the member is already in the group.' do
      Member::GroupAction.new(@member, @group).join
      Member::GroupAdminAction.new(@group_admin, @group, @member).approve

      expect { Member::GroupAdminAction.new(@group_admin, @group, @member).approve } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.member_already_in_group(@member, @group))
    end

    it '- A group admin should not be able to approve a request that has never been sent to admin.' do
      expect { Member::GroupAdminAction.new(@group_admin, @group, @member).approve } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.no_join_request_from_member(@member, @group))
    end
  end

  context '#deny: A group admin deny a join request.' do
    before(:context) do
      @group = FactoryGirl.create(:group, creator: @group_admin)
    end

    it '- A group admin deny a join request.' do
      Member::GroupAction.new(@member, @group).join

      Member::GroupAdminAction.new(@group_admin, @group, @member).deny

      expect(Group::MemberList.new(@group).members.size).to eq(0)
      expect(Group::MemberList.new(@group).requesting.size).to eq(0)
    end
  end

  context '#deny: A group admin tries to deny a join request but get an error.' do
    before(:context) do
      @group = FactoryGirl.create(:group, creator: @group_admin)
    end

    it '- A group admin should not be able to deny a join request if the member is already in the group.' do
      Member::GroupAction.new(@member, @group).join
      Member::GroupAdminAction.new(@group_admin, @group, @member).approve

      expect { Member::GroupAdminAction.new(@group_admin, @group, @member).deny } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.member_already_in_group(@member, @group))
    end

    it '- A group admin should not be able to deny a request that has never been sent to admin.' do
      expect { Member::GroupAdminAction.new(@group_admin, @group, @member).deny } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.no_join_request_from_member(@member, @group))
    end
  end

  context '#remove: A group admin remove a member from a group.' do
    before(:context) do
      @group = FactoryGirl.create(:group, creator: @group_admin)
    end

    it '- A group admin remove a member from the group.' do
      Member::GroupAction.new(@member, @group).join
      Member::GroupAdminAction.new(@group_admin, @group, @member).approve

      Member::GroupAdminAction.new(@group_admin, @group, @member).remove

      expect(Group::MemberList.new(@group).members.map(&:id)).to match_array []
    end
  end

  context '#remove: A group admin tries to remove a member from a group but get an error.' do
    before(:context) do
      @group = FactoryGirl.create(:group, creator: @group_admin)
    end

    it '- A group admin should not be able to remove a member who is not member in the group.' do
      expect { Member::GroupAdminAction.new(@group_admin, @group, @member).remove } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.member_is_not_in_group(@member, @group))
    end

    it '- A group admin should not be able to remove himself.' do
      expect { Member::GroupAdminAction.new(@group_admin, @group, @group_admin).remove } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.cant_remove_yourself)
    end
  end

  context '#promote: A group admin promote a member to be an admin.' do
    before(:context) do
      @group = FactoryGirl.create(:group, creator: @group_admin, need_approve: false)
    end

    it '- A group admin promote a member to be an admin.' do
      Member::GroupAction.new(@member, @group).join
      Member::GroupAdminAction.new(@group_admin, @group, @member).promote

      expect(Group::MemberList.new(@group).admins.map(&:id)).to include @member.id
    end
  end

  context '#promote: A group admin tries to promote a member to be an admin but get an error.' do
    before(:context) do
      @group = FactoryGirl.create(:group, creator: @group_admin, need_approve: false)
    end

    it '- A group admin should not be able to promote a member who is not in the group.' do
      expect { Member::GroupAdminAction.new(@group_admin, @group, @member).promote } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.member_is_not_in_group(@member, @group))
    end

    it '- A group admin should not be able to promote a member who is a group admin.' do
      Member::GroupAction.new(@member, @group).join
      Member::GroupAdminAction.new(@group_admin, @group, @member).promote

      expect { Member::GroupAdminAction.new(@member, @group, @group_admin).promote } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.member_already_admin(@group_admin))
    end
  end

  context '#demote: A group admin demote other admin in a group.' do
    before(:context) do
      @group = FactoryGirl.create(:group, creator: @group_admin, need_approve: false)
    end

    it '- A group admin demote other group admin.' do
      Member::GroupAction.new(@member, @group).join
      Member::GroupAdminAction.new(@group_admin, @group, @member).promote

      Member::GroupAdminAction.new(@group_admin, @group, @member).demote

      expect(Group::MemberList.new(@group).admins.map(&:id)).to include @group_admin.id
    end
  end

  context '#demote: A group admin tries to demote other admin in a group but get an error.' do
    before(:context) do
      @group = FactoryGirl.create(:group, creator: @group_admin, need_approve: false)
    end

    it '- A group admin should not be able to demote group creator.' do
      Member::GroupAction.new(@member, @group).join
      Member::GroupAdminAction.new(@group_admin, @group, @member).promote

      expect { Member::GroupAdminAction.new(@member, @group, @group_admin).demote } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.member_is_group_creator(@group_admin))
    end

    it '- A group admin should not be able to demote a member who is not admin.' do
      Member::GroupAction.new(@member, @group).join
      expect { Member::GroupAdminAction.new(@group_admin, @group, @member).demote } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.member_is_not_admin(@member))
    end

    it '- A group admin should not be able to demote member who is not in the group.' do
      expect { Member::GroupAdminAction.new(@group_admin, @group, @member).demote }\
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.member_is_not_in_group(@member, @group))
    end
  end

  context '#promote #remove: A group admin tries to remove group creator from a group.' do
    before(:context) do
      @group = FactoryGirl.create(:group, creator: @group_admin, need_approve: false)
    end

    it '- A group admin should not be able to remove group creator from the group.' do
      Member::GroupAction.new(@member, @group).join
      Member::GroupAdminAction.new(@group_admin, @group, @member).promote

      expect { Member::GroupAdminAction.new(@member, @group, @group_admin).remove } \
        .to raise_error(
          ExceptionHandler::UnprocessableEntity,
          GuardMessage::GroupAdminAction.member_is_group_creator(@group_admin))
    end
  end
end

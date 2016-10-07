# == Schema Information
#
# Table name: group_members
#
#  id           :integer          not null, primary key
#  member_id    :integer
#  group_id     :integer
#  is_master    :boolean          default(TRUE)
#  created_at   :datetime
#  updated_at   :datetime
#  active       :boolean          default(FALSE)
#  invite_id    :integer
#  notification :boolean          default(TRUE)
#

require 'rails_helper'

RSpec.describe GroupMember, type: :model do
  
  before(:all) do
    @group = create(:empty_group)
    @member = create(:member)
  end

  it 'can be created with an empty group and a member if the member is the admin.' do
    GroupMember.create!(attributes_for(:group_member_admin).merge(member: @member, group: @group))
  end

  it 'cannot be created with an empty group and a member if the member is not the admin.' do
    expect { GroupMember.create!(attributes_for(:group_member).merge(member: @member, group: @group)) }
      .to raise_error(ActiveRecord::RecordInvalid)

    expect(GroupMember.find_by(member: @member, group: @group)).to be_nil
  end

  it 'cannot be destroyed if the member is the last admin of the group.' do
    group_member = GroupMember.create!(attributes_for(:group_member_admin).merge(member: @member, group: @group))

    expect { group_member.destroy }
      .to raise_error(ExceptionHandler::Forbidden)

    expect(GroupMember.find_by(member: @member, group: @group)).not_to be_nil
  end
end

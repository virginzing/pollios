# == Schema Information
#
# Table name: groups
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  public           :boolean          default(FALSE)
#  photo_group      :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  authorize_invite :integer
#  description      :text
#  leave_group      :boolean          default(TRUE)
#  group_type       :integer
#  cover            :string(255)
#  admin_post_only  :boolean          default(FALSE)
#  need_approve     :boolean          default(TRUE)
#  public_id        :string(255)
#  visible          :boolean          default(TRUE)
#  system_group     :boolean          default(FALSE)
#  virtual_group    :boolean          default(FALSE)
#  member_id        :integer
#  cover_preset     :string(255)      default("0")
#  exclusive        :boolean          default(FALSE)
#  deleted_at       :datetime
#  opened           :boolean          default(FALSE)
#

require 'test_helper'

class GroupTest < ActiveSupport::TestCase

  def setup
    @member = members(:one)
    @friend_two = members(:two)
    @friend_three = members(:three)
    @params = {
      member_id: @member.id,
      name: "New Group",
      description: "YEH"
    }
  end

  def test_should_not_save_without_name
    group = Group.new
    assert_not group.save
  end

  def test_should_have_the_necessary_required_validators
    group = Group.new
    assert_not group.valid?
    assert_equal([:name], group.errors.keys)
  end

  def test_build_group
    assert_difference "Group.count", 1 do
      @group = Group.build_group(@member, @params)
    end
    assert @group.present?
  end

  def test_build_group_that_there_is_one_member
    @group = Group.build_group(@member, @params)
    assert_equal(Group::MemberList.new(@group).active.size, 1)
  end

  def test_build_group_when_group_is_public
    params = {
      member_id: @member.id,
      name: "Public Group",
      public: true
    }

    group = Group.build_group(@member, params)
    assert group.public
  end

  def test_build_group_with_friend
    str_friend_id = "#{@friend_two.id}, #{@friend_three.id}"
    params = {
      member_id: @member.id,
      name: "Public Group",
      friend_id: str_friend_id
    }

    group = Group.build_group(@member, params)
    assert group.present?
    assert_equal(Group::MemberList.new(group).pending.size, 2)
  end
end

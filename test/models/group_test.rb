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
    assert_equal(Group::ListMember.new(@group).active.size, 1)
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
    assert_equal(Group::ListMember.new(group).pending.size, 2)
  end
end

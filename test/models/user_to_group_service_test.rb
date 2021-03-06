require 'test_helper'

class UserToGroupServiceTest < ActiveSupport::TestCase

  def setup
    @member = members(:one)
    @member_two = members(:two)
    @group = groups(:two)

    @init = UserToGroupService.new({
      member_id: @member.id,
      group_id: @group.id,
      fullname: "w"
    })
  end

  def test_that_search_users
    assert @init.users.present?
    assert_equal(@init.users.size, 1)
  end

end

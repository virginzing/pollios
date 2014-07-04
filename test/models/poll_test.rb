require 'test_helper'

class PollTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "title and member should be presence" do
    # poll = Poll.new(member_id: 1, title: "ieie")
    poll = polls(:two)

    assert_not poll.save, "Title and member have to be presence"
  end
end

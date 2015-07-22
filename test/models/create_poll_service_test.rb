require 'test_helper'

class CreatePollServiceTest < ActiveSupport::TestCase

  def setup
    @poll = CreatePollService.new(members(:one), {})
  end

  def test_that_poll_not_in_public_by_default
    assert_not @poll.in_public?
  end

  def test_that_poll_in_public
    @poll.params = {
      is_public: true
    }

    assert @poll.in_public?
  end

  def test_that_poll_not_in_public
    @poll.params = {
      is_public: false
    }

    assert_not @poll.in_public?
  end

  def test_that_poll_not_in_group_by_default
    assert_not @poll.in_group?
  end

  def test_that_poll_in_group
    @poll.params = {
      group_id: "1,2"
    }

    assert @poll.in_group?
  end

  def test_that_it_have_a_list_choices
    @poll.params = {
      choices: ["A", "B"]
    }

    assert_equal(@poll.list_choices, ["A", "B"])
  end

  def test_that_it_have_two_choices_count
    @poll.params = {
      choices: ["A", "B"]
    }

    assert_equal(@poll.calculate_choices, 2)
  end

end

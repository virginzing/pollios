require 'test_helper'

class CreatePollServiceTest < ActiveSupport::TestCase

  def setup
    params = {
      title: "Mockup",
      choices: ["1", "2"]
    }
    @poll = CreatePollService.new(members(:one), params)
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

  def test_that_it_have_a_type_poll_default_is_freeform
    assert_equal(@poll.set_type_poll, "freeform")
  end

  def test_that_it_have_a_qrcode_key
    assert @poll.poll_attributes[:qrcode_key].present?
  end

  def test_that_it_have_a_show_result_is_true
    assert @poll.poll_attributes[:show_result]
  end

  def test_that_it_have_a_qr_only_is_false
    assert_not @poll.poll_attributes[:qr_only]
  end

  def test_that_it_have_a_require_info_is_false
    assert_not @poll.poll_attributes[:require_info]
  end

  def test_that_it_have_a_priority_is_zero
    assert_equal(@poll.new_poll.priority, 0)
  end

  def test_that_it_have_tags_from_title
    @poll.params = {
      title: "wow #nut #coding"
    }

    assert_equal(@poll.split_tags_form_title, ["nut", "coding"])
  end

  def test_that_it_have_to_watching_poll
    poll = @poll.create!
    assert_equal(poll.watcheds.count, 1)
  end

end

require 'test_helper'

class CreatePollServiceTest < ActiveSupport::TestCase

  def setup
    @member = members(:one)
    @poll = CreatePollService.new(@member, {
      title: "Mockup",
      choices: ["1", "2"]
    })
    @group = groups(:one)
    @group_two = groups(:two)
    @celebrity = members(:celebrity)
  end

  def test_that_citizen_have_point
    assert @poll.member_have_point?
  end

  def test_that_poll_not_in_public_by_default
    assert_not @poll.in_public?
  end

  def test_that_poll_in_public
    @poll.params[:is_public] = true

    assert @poll.in_public?
  end

  def test_that_poll_not_in_public
    @poll.params[:is_public] = false

    assert_not @poll.in_public?
  end

  def test_that_poll_not_in_group_by_default
    assert_not @poll.in_group?
  end

  def test_that_poll_in_group
    @poll.params[:group_id] = "1,2"

    assert @poll.in_group?
  end

  def test_that_it_have_a_list_choices
    @poll.params[:choices] = ["A", "B"]

    assert_equal(@poll.list_choices, ["A", "B"])
  end

  def test_that_it_have_two_choices_count
    @poll.params[:choices] = ["A", "B"]

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
    @poll.params[:title] = "wow #nut #coding"

    assert_equal(@poll.split_tags_form_title, ["nut", "coding"])
  end

  def test_that_it_have_to_watching_poll
    poll = @poll.create!
    assert_equal(poll.watcheds.count, 1)
  end

  def test_that_it_can_create_the_poll
    assert_difference "Poll.count", 1 do
      @poll.create!
    end
  end

  def test_that_it_can_create_poll_to_feed
    assert_difference "PollMember.count", 1 do
      @poll.create!
    end
  end

  def test_that_validate_success_when_post_poll_to_friend
    @poll.params[:type_poll] = "binary"
    @poll.params[:is_public] = false

    assert @poll.validate_that_can_create!
  end

  def test_that_alert_message_is_nil_when_not_post_to_group
    @poll.params[:type_poll] = "binary"
    @poll.params[:is_public] = false

    assert_nil @poll.alert_message
  end

  def test_that_available_post_to_group_ids_when_nost_post_to_group
    @poll.params[:type_poll] = "binary"
    @poll.params[:is_public] = false
    assert_empty @poll.available_post_to_group_ids
  end

  def test_that_post_to_group_ids
    @poll.params[:group_id] = "1,2"
    assert_equal(@poll.post_to_group_ids, [1,2])
  end

  def test_that_thumnail_type_default_is_0
    assert_equal(@poll.poll_attributes[:thumbnail_type], 0)
  end

  def test_that_convert_list_original_images
    @poll.params[:original_images] =  ["http://res.cloudinary.com/code-app/image/upload/v1436275533/mkhzo71kca62y9btz3bd.png",
                        "http://res.cloudinary.com/code-app/image/upload/v1433344706/dcxanj8qcc1fal6r0rud.png"]

    assert_equal(@poll.convert_list_original_images, ["v1436275533/mkhzo71kca62y9btz3bd.png", "v1433344706/dcxanj8qcc1fal6r0rud.png"])
  end

  def test_class_image_url
    @image_url = ImageUrl.new("http://res.cloudinary.com/code-app/image/upload/v1436275533/mkhzo71kca62y9btz3bd.png")

    assert_equal(@image_url.split_cloudinary_url, "v1436275533/mkhzo71kca62y9btz3bd.png")
  end

  def test_when_post_poll_to_public_with_default_value
    @poll.params[:is_public] = true

    assert @poll.validate_that_can_create!
    assert @poll.in_public?
    assert @poll.new_poll.public
    assert @poll.create!
  end

  def test_that_add_poll_to_feed_when_poll_create_public_or_friend
    poll = @poll.create!

    assert poll.poll_members.present?
  end

  def test_that_add_poll_to_group_when_poll_create_to_group
    @poll.params[:group_id] = @group.id.to_s
    poll = @poll.create!

    assert poll.poll_groups.present?
  end

  def test_that_add_poll_group_but_no_longer_this_group
    @poll.params[:group_id] = @group_two.id.to_s
    exception = assert_raise(ExceptionHandler::CustomError) { @poll.create! }

    alert_message = "You're no longer in second group."
    assert_equal(alert_message, exception.message)
  end

  def test_add_poll_to_more_group_but_no_longer_some_group
    @poll.params[:group_id] = [@group.id, @group_two.id].join(",")

    assert_equal(@poll.available_post_to_group_ids, [@group.id])
    assert @poll.create!
    assert_equal(@poll.alert_message, "This poll don't show in second group because you're no longer these group.")
  end

  def test_that_citizen_have_a_point_when_post_to_pubic
    @poll.params[:is_public] = true

    assert @poll.create!
  end

  def test_that_citizen_is_not_a_point_when_post_to_public
    @poll.creator = members(:citizen_no_point)
    @poll.params[:is_public] = true

    exception = assert_raise(ExceptionHandler::UnprocessableEntity) { @poll.create! }
    assert_equal(ExceptionHandler::Message::Poll::POINT_ZERO, exception.message)
  end

  def test_add_poll_with_1_image
    image_url = "http://res.cloudinary.com/code-app/image/upload/v1436275533/mkhzo71kca62y9btz3bd.png"
    @poll.params[:photo_poll] = image_url
    @poll.params[:original_images] = [image_url]
    poll = @poll.create!

    assert_equal(poll.photo_poll_identifier, "v1436275533/mkhzo71kca62y9btz3bd.png")
    assert_equal(poll.get_original_images.size, 1)
  end

  def test_add_poll_with_2_images
    image_url_one = "http://res.cloudinary.com/code-app/image/upload/v1436275533/mkhzo71kca62y9btz3bd.png"
    image_url_two = "http://res.cloudinary.com/code-app/image/upload/v1433344706/dcxanj8qcc1fal6r0rud.png"
    @poll.params[:photo_poll] = image_url_one
    @poll.params[:original_images] = [image_url_one, image_url_two]
    poll = @poll.create!

    assert poll
    assert_equal(poll.get_original_images.size, 2)
  end

  def test_decrease_point_when_citizen_create_poll_to_public
    @poll.params[:is_public] = true
    assert_equal(@member.point, 5)

    @poll.create!
    assert_equal(@member.point, 4)
  end

  def test_not_decrease_point_when_celebrity_create_poll_to_public
    @poll.params[:is_public] = true
    @poll.creator = @celebrity
    assert_equal(@celebrity.point, 5)

    @poll.create!
    assert_equal(@celebrity.point, 5)
  end





end

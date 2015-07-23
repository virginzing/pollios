class CreatePollService
  include PollsHelper

  attr_accessor :params, :creator

  def initialize(creator, params)
    @creator = creator
    @params = params
  end

  def in_public?
    poll_public_status
  end

  def in_group?
    in_group_status
  end

  def list_choices
    raise ExceptionHandler::UnprocessableEntity, "List choices not found." unless params[:choices].present?
    raise ExceptionHandler::UnprocessableEntity, "List choices should have more than one choices." unless list_choices_checking
    params[:choices]
  end

  def init_list_choices_for_new_poll
    init_list_choices = []
    list_choices.each do |choice|
      init_list_choices << {
        answer: choice
      }
    end
    init_list_choices
  end

  def list_choices_checking
    return unless params[:choices].class == Array
    return unless params[:choices].size > 1
    true
  end

  def calculate_choices
    list_choices.size
  end

  def set_type_poll
    Poll.type_poll.default_value
  end

  def is_citizen_and_having_point?
    creator.citizen? && creator.point > 0
  end

  def split_tags_form_title
    split_tags = []
    params[:title].gsub(/\B#([[:word:]]+)/) { split_tags << $1 }
    return split_tags
  end

  def poll_attributes
    params[:member_id] = creator.id
    params[:expire_date] = convert_expire_date
    params[:public] = poll_public_status
    params[:in_group] = in_group_status
    params[:in_group_ids] = in_group_ids
    params[:series] = false
    params[:poll_series_id] = 0
    params[:choice_count] = calculate_choices
    params[:campaign_id] = 0
    params[:recurring_id] = 0
    params[:qrcode_key] = generate_qrcode_key
    params[:member_type] = creator.member_type_text
    params[:show_result] = true
    params[:require_info] = false
    params[:qr_only] = false
    params[:priority] = 0
    params[:thumbnail_type] = params[:thumbnail_type] || 0
    params[:choices_attributes] = init_list_choices_for_new_poll
    params.except(:choices, :is_public, :group_id, :photo_poll, :original_images)
  end

  def new_poll
    @poll = Poll.new(poll_attributes)
  end

  def create!
    Poll.transaction do
      validate_that_can_create!
      if new_poll.save
        update_photo_poll if params[:photo_poll].present?
        additional_poll_attachments if params[:original_images].present?
        decrease_point! if is_citizen_and_having_point? && in_public?
        creatable_tagging!
        watching_poll!
        add_poll_to_feed!
        add_poll_to_group! if in_group?
        add_poll_to_company! if creator.company?
        tracking_activtiy_feed! if in_group?
        MemberActiveRecord.record_member_active(creator)
        PollStats.create_poll_stats(@poll)
        Activity.create_activity_poll(creator, @poll, 'Create')
        @poll
      else
        raise ExceptionHandler::UnprocessableEntity, @poll.errors.full_messages.join(", ")
      end
    end
  end

  def validate_that_can_create!
    if in_public?
      raise ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Poll::POINT_ZERO unless is_citizen_and_having_point?
    else
      if in_group? && !creator.company?
        unless available_post_to_group_ids.size > 0
          group_names = Group.where(id: post_to_group_ids)
          alert_message = "You're no longer in #{group_names.map(&:name).join(', ')}."
          raise ExceptionHandler::CustomError, AlertSerializer.new({ response_status: "OK", alert_message: alert_message}).to_json
        end
      end
    end
    true
  end

  def alert_message
    if (available_post_to_group_ids.size != post_to_group_ids.size) && in_group?
      group_names = Group.where(id: (post_to_group_ids - available_post_to_group_ids)).map(&:name).join(', ')
      alert_message = "This poll don't show in #{group_names} because you're no longer these group."
    end
    alert_message
  end

  def available_post_to_group_ids
    list_groups_active.map(&:id) & post_to_group_ids
  end

  def post_to_group_ids
    in_group_ids.split(",").map(&:to_i)
  end

  def convert_list_original_images
    params[:original_images].collect!{ |image_url| ImageUrl.new(image_url).split_cloudinary_url }
  end

  private

  def list_groups_active
    @list_groups_active ||= Member::ListGroup.new(creator).active
  end

  def add_poll_to_feed!
    @poll.poll_members.create!({
      member: creator,
      share_poll_of_id: 0,
      series: false,
      public: poll_public_status,
      expire_date: convert_expire_date,
      in_group: in_group_status
    })
  end

  def query_groups
    @query_groups ||= Group.where(id: available_post_to_group_ids)
  end

  def add_poll_to_group!
    query_groups.each do |group|
      group.poll_groups.create!({
        poll: @poll,
        member: creator
      })
    end
  end

  def add_poll_to_company!
    PollCompany.create_poll(@poll, creator.get_company, :mobile)
  end

  def tracking_activtiy_feed!
    Company::TrackActivityFeedPoll.new(creator, in_group_ids, @poll, "create").tracking
  end

  def decrease_point!
    creator.with_lock do
      creator.point -= 1
      creator.save!
    end
  end

  def creatable_tagging!
    if split_tags_form_title.size > 0
      split_tags_form_title.each do |tag_name|
        @poll.tags << Tag.where(name: tag_name).first_or_create!
      end
    end
  end

  def watching_poll!
    WatchPoll.new(creator, @poll.id).watching
  end

  def poll_public_status
    if params[:is_public]
      true
    else
      false
    end
  end

  def in_group_status
    in_group = false
    in_group = true if params[:group_id].present?
    return in_group
  end

  def in_group_ids
    in_group_ids = "0"
    in_group_ids = params[:group_id] if in_group_status
    return in_group_ids
  end

  def convert_expire_date
    expire_date_default = Time.zone.now + 100.years
    expire_date_default = Time.zone.now + params[:expire_within].to_i.days if params[:expire_within].present?
    return expire_date_default
  end

  def generate_qrcode_key
    begin
      qrcode_key = SecureRandom.hex(6)
    end while Poll.exists?(qrcode_key: qrcode_key)
    qrcode_key
  end

  def additional_poll_attachments
    convert_list_original_images.each_with_index do |url_attachment, index|
      poll_attachment = poll_attachments.create!(order_image: index + 1)
      poll_attachment.update_column(:image, url_attachment)
    end
  end

  def update_photo_poll
    init_image_url = ImageUrl.new(params[:photo_poll])
    @poll.update_column(:photo_poll, init_image_url.split_cloudinary_url)
  end

end

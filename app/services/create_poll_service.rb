class CreatePollService
  include PollsHelper

  attr_accessor :params

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

  def list_choices_checking
    return unless params[:choices].class == Array
    return unless params[:choices].size > 1
    true
  end

  def calculate_choices
    list_choices.size
  end

  def default_type_poll
    Poll.type_poll.default_value
  end

  def poll_attributes
    {
      member_id: @creator.id,
      title: params[:title],
      expire_date: convert_expire_date,
      public: poll_public_status,
      in_group: in_group_status,
      in_group_ids: in_group_ids,
      series: false,
      poll_series_id: 0,
      choice_count: calculate_choices,
      campaign_id: 0,
      recurring_id: 0,
      qrcode_key: generate_qrcode_key,
      type_poll: params[:type_poll] || default_type_poll
    }
  end

  def new_poll
    @poll = Poll.new(poll_attributes)
  end

  def create!
    if new_poll.save
      if in_public?

      else
        if in_group?

        else

        end
      end
    else
      raise ExceptionHandler::UnprocessableEntity, @poll.errors.full_messages.join(', ')
    end

  end

  private

  def poll_public_status
    default_public = false
    default_public = params[:is_public] if params[:is_public].present?
    return default_public
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
    expire_date_default = Time.zone.now + params[:expire_date].to_i.days if params[:expire_date].present?
    return expire_date_default
  end

  def generate_qrcode_key
    begin
      qrcode_key = SecureRandom.hex(6)
    end while Poll.exists?(qrcode_key: qrcode_key)
    qrcode_key
  end

end

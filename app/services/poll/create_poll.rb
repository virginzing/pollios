class Poll::CreatePoll
  include ActiveModel::Validations

  validates_presence_of :member_id, :title

  def poll
    @poll ||= Poll.new
  end

  def create(params)
    Poll.transaction do
      begin
        @params = params
        poll.attributes = @params.slice!(:choices, :is_public)

        if poll.valid?
          set_default_value
          generate_qrcode
          poll.save
          create_choices
          true
        else
          false
        end
      end
    end
  end

  def raise_error
    {
      error: poll.errors.full_messages
    }
  end

  def set_expire_date
    @expire_date ||= Time.now + 100.years.to_i
  end

  def choice_list
    @params[:choices].presence || []
  end

  def set_public_poll
    @params[:is_public]
  end

  private

  def set_default_value
    poll.poll_series_id = 0
    poll.in_group_ids = "0"
    poll.campaign_id  = 0
    poll.public = set_public_poll
    poll.expire_date  = set_expire_date
    poll.choice_count = choice_list.size
    poll.member_type = poll.member.member_type_text
  end

  def create_choices
    choice_list.collect {|choice| Choice.create!(poll_id: poll.id, answer: choice)} if choice_list.size > 0
  end

  def generate_qrcode
    begin
      poll.qrcode_key = SecureRandom.hex(6)
    end while Poll.exists?(qrcode_key: poll.qrcode_key)
  end

end

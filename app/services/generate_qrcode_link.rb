class GenerateQrcodeLink

  def initialize(poll_or_questionnaire)
    @poll_or_questionnaire = poll_or_questionnaire
    @series = false
    @host_link = Rails.env.production? ? 'http://pollios.com' : 'http://192.168.1.17:3000'
    @custom_url = '/m/polls?key='
    @redirect_url = '/qrcode?key='
    @open_app = 'pollios://poll?poll_id='
  end

  def get_link
    @host_link + @custom_url + secret_qrcode_key
  end

  def get_redirect_link
    @host_link + @redirect_url + secret_qrcode_key
  end

  def link
    @open_app + encode
  end

  # private

  def questionnaire?
    @poll_or_questionnaire.is_a? PollSeries
  end

  def series_key
    questionnaire? ? "&s=t" : "&s=f"
  end

  def get_qrcode_key
    "&qr_key=" + @poll_or_questionnaire.qrcode_key
  end

  def secret_qrcode_key
    string = "id=" + @poll_or_questionnaire.id.to_s + get_qrcode_key + series_key
    Base64.urlsafe_encode64(string)
  end

  def encode
    custom = (@poll_or_questionnaire.id + ENV['POLL_URL_ENCODER_KEY'].to_i).to_s
    Base64.urlsafe_encode64(custom)
  end
  
end
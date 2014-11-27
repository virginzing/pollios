class GenerateQrcodeLink

  def initialize(poll_or_questionnaire)
    @poll_or_questionnaire = poll_or_questionnaire
    @series = false
    @host_link = Rails.env.production? ? 'http://pollios.com' : 'http://localhost:3000'
    @custom_url = '/m/polls?key='
  end

  def get_link
    @host_link + @custom_url + secret_qrcode_key
  end

  private

  def questionnaire?
    @poll_or_questionnaire.is_a? PollSeries
  end

  def series_key
    questionnaire? ? "&s=t" : "&s=f"
  end

  def secret_qrcode_key
    string = "id=" + @poll_or_questionnaire.qrcode_key + series_key
    Base64.urlsafe_encode64(string)
  end
  
  
end
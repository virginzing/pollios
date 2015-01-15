class GenerateSpecialQrcodeLink
  def initialize(code, type)
    @code = code
    @type = type
    @host_link = Rails.env.production? ? 'http://pollios.com' : 'http://localhost:3000'
    @custom_url = '/m/members?key='
    @redirect_url = '/qrcode_member?key='
  end

  def custom_url
    if @type == "member"
      '/m/members?key='
    end
  end

  def get_link
    @host_link + custom_url + qrcode_key
  end

  def get_redirect_link
    @host_link + @redirect_url + qrcode_key
  end
  
  private

  def qrcode_key
    string = "code=" + @code + "&type=" + @type
    Base64.urlsafe_encode64(string)
  end
  
end
class Authentication

  def initialize(params)
    @params = params
    @new_member = false
    @new_member_provider = false
  end

  def member
    @member ||= member_from_authen
  end

  def authenticated?
    member.present?    
  end  

  def name
    @params["fullname"] || @params[:name]
  end

  def avatar
    @params["avatar_thumbnail"] || @params[:user_photo]
  end

  def generate_token
    @params["token"] || SecureRandom.hex
  end

  def province
    @params["province"]["id"] if @params["province"].present? || @params[:province_id]
  end

  def pid
    @params["sentai_id"] || @params[:id]
  end

  def email
    @params["email"] || @params[:email]
  end

  def username
    @params["username"] || @params[:username]
  end

  def birthday
    @params["birthday"] || @params[:birthday]
  end

  def gender
    @params["gender"] || @params[:gender]
  end

  def member_type
    @params["member_type"]
  end
  
  private

  def member_from_authen
    @member = Member.where(email: email).first_or_initialize do |member|
      member.sentai_name = name
      member.username = check_username(username)
      member.email = email
      member.avatar = avatar
      member.birthday = birthday
      member.gender = gender.to_i
      member.province_id = province
      member.member_type = member_type
      member.save
      @new_member = true
    end

    if @member
      @member_provider = @member.providers.where("name = ?", @params["provider"]).first_or_initialize do |provider|
        provider.name = @params["provider"]
        provider.pid = pid
        provider.token = generate_token
        provider.save
        @new_member_provider = true
      end
    end

    update_member(@member) unless @new_member
    update_member_provider(@member_provider) unless @new_member_provider

    @member
  end

  def update_member(member)
    member.update_attributes!(sentai_name: member.sentai_name || name, username: member.username || username, avatar: member.avatar || avatar, birthday: member.birthday || birthday)
  end

  def update_member_provider(member_provider)
    member_provider.update_attributes!(token: generate_token)
  end

  def check_username(user_name)
    find_username = Member.where(username: user_name)
    return find_username.present? ? nil : user_name
  end

end


class Authentication

  def initialize(params)
    @params = params
    @new_member = false
    @new_member_provider = false
    @default_member_type = :citizen
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
    Authentication.generate_api_token
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
    @params["member_type"] || @default_member_type
  end

  
  private

  def member_from_authen
    @member = Member.where(email: email).first_or_create do |member|
      member.sentai_name = name
      member.username = check_username
      member.email = email
      member.birthday = birthday
      member.gender = gender.to_i
      member.province_id = province
      member.member_type = member_type
      member.save
      @new_member = true
    end


    if @member
      @member.update_column(:avatar, avatar) if avatar.present?
      
      @member_provider = @member.providers.where("name = ?", @params["provider"]).first_or_initialize do |provider|
        provider.name = @params["provider"]
        provider.pid = pid
        provider.token = generate_token
        provider.save
        @new_member_provider = true
      end

    if @new_member
      follow_pollios
      UserStats.create_user_stats(@new_member, @params["provider"])
    end

    end

    update_member(@member) unless @new_member
    update_member_provider(@member_provider) unless @new_member_provider

    @member
  end

  def follow_pollios
    find_pollios = Member.find_by_email("pollios@pollios.com")
    if find_pollios.present?
      Friend.create!(follower_id: @member.id, followed_id: find_pollios.id, status: :nofriend, following: true) unless @member.id == find_pollios.id
    end
  end

  def update_member(member)
    unless username.present?
      member.update(sentai_name: name, avatar: avatar, birthday: birthday)
    else
      member.update(sentai_name: name, username: check_username, avatar: avatar, birthday: birthday)
    end
  end

  def update_member_provider(member_provider)
    member_provider.update_attributes!(token: generate_token)
  end

  def check_username
    find_username = Member.where(username: username)
    if find_username.present?
      @username = nil
    else
      @username = username
    end
    @username
  end

  def self.generate_api_token
    begin
      token = SecureRandom.hex
    end while Provider.exists?(token: token)
    return token
  end
end


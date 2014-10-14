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

  def web_login
    @params["web_login"]
  end

  def approve_brand
    @member.approve_brand
  end

  def approve_company
    @member.approve_company
  end

  def get_member_type
    member.member_type_text  
  end

  def authenticated?
    member.present? && member.normal?
  end

  def activate_account?
    check_activate_account
  end  

  def check_valid_member?
    !member.blacklist?
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

  def generate_auth_token
    Authentication.generate_auth_token
  end

  def province
    @params["province"]["id"] if @params["province"].present?
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

  def approved_brand
    approve_brand = @params["approve_brand"]
    approve_brand.present? ? true : false
  end

  def address
    @params["address"]
  end

  def first_signup
    @new_member
  end

  def error_message
    if member.blacklist?
      "This account is banned"
    else
      "Invalid email or password."
    end
  end

  private

  def member_from_authen
    @member = Member.where(email: email).first_or_create do |member|
      member.fullname = name
      member.email = email
      member.member_type = member_type
      member.approve_brand = approved_brand
      if web_login.present?
        member.auth_token = generate_auth_token
      end
      member.setting = { "post_poll"=>"friend_following", "vote_poll"=> true, "comment_poll"=> true }
      member.save!
      @new_member = true
    end

    if @member
      if web_login.present?
        update_new_token unless @member.auth_token.present?
      end

      @member_provider = @member.providers.where("name = ?", @params["provider"]).first_or_initialize do |provider|
        provider.name = @params["provider"]
        provider.pid = pid
        provider.token = generate_token
        provider.save
        @new_member_provider = true
      end

      if @new_member
        follow_pollios
        add_new_group_company if member_type == "3"
        @member.update_column(:avatar, avatar) if avatar.present?
        UserStats.create_user_stats(@new_member, @params["provider"])
      end

    end

    update_member(@member) unless @new_member
    update_member_provider(@member_provider) unless @new_member_provider

    @member
  end

  def update_new_token
    @member.update!(auth_token: generate_auth_token)
  end

  def follow_pollios
    find_pollios = Member.find_by_email("pollios@gmail.com")
    if find_pollios.present?
      puts "member2 => #{@member.id}"
      Friend.create!(follower_id: @member.id, followed_id: find_pollios.id, status: :nofriend, following: true) unless @member.id == find_pollios.id
    end
  end

  def add_new_group_company
    company = Company.create!(name: name, address: address, member_id: member.id)
    group = Group.create(name: name, authorize_invite: :master, public: false, leave_group: false,)
    GroupCompany.create!(group_id: group.id, company_id: company.id, main_group: true)
  end

  def update_member(member)
    member.update!(fullname: member.fullname.presence || name, birthday: member.birthday.presence || birthday)
  end

  def update_member_provider(member_provider)
    member_provider.update_attributes!(token: generate_token)
  end

  # def check_username
  #   find_username = Member.where(username: username).first
  #   if find_username.present?
  #     if find_username.id == @member.id
  #       @username = username
  #     else
  #       @username = nil
  #     end
  #   else
  #     @username = username
  #   end
  #   @username
  # end

  def self.generate_api_token
    begin
      token = SecureRandom.hex
    end while Provider.exists?(token: token)
    return token
  end

  def self.generate_auth_token
    begin
      auth_token = SecureRandom.urlsafe_base64
    end while Member.exists?(auth_token: auth_token)
    return auth_token
  end

  def check_activate_account
    member.bypass_invite || member.member_invite_codes.present? || member.brand? || approve_company
  end
end

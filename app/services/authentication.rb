class Authentication

  def initialize(params)
    @params = params
    @new_member = false
    @new_member_provider = false
    @new_member_api_token = false
    @default_member_type = :citizen
  end

  def provider
    @params[:provider]
  end

  def member
    @member ||= provider == "facebook" ? member_from_facebook : member_from_authen
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
    true || check_activate_account
  end  

  def check_valid_member?
    !member.blacklist?
  end

  def company_id
    @params["company_id"]
  end

  def select_service
    @params["select_service"]
  end

  def create_member_via_company?
    company_id.present?
  end

  def name
    @params["fullname"] || @params[:name]
  end

  def avatar
    @params["avatar_thumbnail"] || @params[:user_photo]
  end

  def app_id
    @params["app_id"]
  end

  def generate_token
    Authentication.generate_api_token
  end

  def generate_auth_token
    Authentication.generate_auth_token
  end

  def generate_api_token
    Authentication.new_generate_api_token
  end

  def get_api_token
    @member_api_token.token
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

  def register_status
    @params["register"]
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
      member.waiting = check_waiting
      member.fullname = name
      member.email = email
      member.member_type = member_type
      member.register = register_status
      member.approve_brand = approved_brand
      if web_login.present?
        member.auth_token = generate_auth_token
      end
      member.created_company = true if create_member_via_company? || select_service.present?
      member.setting = member_setting

      member.save!
      @new_member = true
    end

    if @member
      if web_login.present?
        update_new_token unless @member.auth_token.present?
      end

      # @member_provider = @member.providers.where("name = ?", @params["provider"]).first_or_initialize do |provider|
      #   provider.name = @params["provider"]
      #   provider.pid = pid
      #   provider.token = generate_token
      #   provider.save
      #   @new_member_provider = true
      # end

      if app_id.present?
        @member_api_token = @member.api_tokens.where("app_id = ?", app_id).first_or_initialize do |api_token|
          api_token.app_id = app_id
          api_token.token = generate_api_token
          api_token.save
        end
      end

      if @new_member
        follow_pollios
        add_new_group_company if member_type == "3"
        join_group_automatic if create_member_via_company?
        join_company_member if create_member_via_company?
        @member.update_column(:avatar, avatar) if avatar.present?
        UserStats.create_user_stats(@member, @params["provider"])
      end

    end

    # update_member(@member) unless @new_member
    # update_member_provider(@member_provider) unless @new_member_provider

    # if uuid.present?
    #   update_new_api_token(@member_api_token) unless @new_member_api_token
    # end

    @member
  end

  def member_from_facebook
    find_provider = Provider.where(name: "facebook", pid: pid).first

    unless find_provider.present?
      member = Member.create!(fullname: name, member_type: member_type, auth_token: generate_auth_token, setting: member_setting, register: register_status)
      find_provider = member.providers.create!(name: "facebook", pid: pid, token: generate_token)
      @new_member = true
    end

    @member = find_provider.member

    if @new_member
      follow_pollios
      UserStats.create_user_stats(@member, @params["provider"])
    else
      find_provider.update_columns(token: generate_token, updated_at: Time.zone.now)
    end
    @member
  end

  def check_waiting
    waiting = false
    limit_member = Figaro.env.limit_member.to_i

    if create_member_via_company? || select_service.present?
      waiting = false
    else
      unless limit_member > Member.unscoped.where(created_company: false).count
        waiting = true     
      end
    end
    
    waiting
  end

  def update_new_token
    @member.update!(auth_token: generate_auth_token)
  end


  def join_group_automatic
    find_main_group = Company.find(company_id.to_i).main_groups.first
    find_main_group.group_members.create!(member_id: @member.id, active: true, is_master: false)
    find_main_group.increment!(:member_count)
  end

  def join_company_member
    CompanyMember.add_member_to_company(@member, Company.find(company_id.to_i))
  end

  def follow_pollios
    # puts "member => #{@member}"
    find_pollios = Member.find_by_email("pollios@gmail.com")
    if find_pollios.present?
      Friend.create!(follower_id: @member.id, followed_id: find_pollios.id, status: :nofriend, following: true) unless @member.id == find_pollios.id
    end
  end

  def add_new_group_company
    company = Company.create!(name: name, address: address, member_id: member.id, using_service: select_service)
    company.feedback_recurrings.create!(period: '00:00')
    group = Group.create(name: name, authorize_invite: :master, public: false, leave_group: false, group_type: :company)
    GroupCompany.create!(group_id: group.id, company_id: company.id, main_group: true)
  end

  def update_member(member)
    member.update!(fullname: member.fullname.presence || name, birthday: member.birthday.presence || birthday)
  end

  def update_member_provider(member_provider)
    member_provider.update_attributes!(token: generate_token)
  end

  def update_new_api_token(member_api_token)
    member_api_token.update_attributes!(token: generate_api_token)
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

  def member_setting
    { 
      "post_poll"=>"friend_following", 
      "vote_poll"=> true, 
      "comment_poll"=> true 
    }
  end

  def self.generate_api_token
    begin
      token = SecureRandom.hex
    end while Provider.exists?(token: token)
    return token
  end

  def self.new_generate_api_token
    begin
      token = SecureRandom.hex
    end while ApiToken.exists?(token: token)
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

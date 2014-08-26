class MemberMailer < ActionMailer::Base
  default from: "nuttapon@code-app.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.member_mailer.password_reset.subject
  #
  def password_reset(member, password_reset_token)
    @member = member
    @password_reset_token = password_reset_token

    mail to: member.email, subject: 'Password Reset'
  end

  def send_invite_group(email_url, group_name, invite_code)
    @group_name = group_name
    @invite_code = invite_code
    
    mail to: email_url, subject: "Your invite code from #{@group_name}"
  end

end

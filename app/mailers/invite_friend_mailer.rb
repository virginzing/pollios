class InviteFriendMailer < ActionMailer::Base
  default from: "polliosadmin@code-app.com"


  def invite_list_email(sender, list_email)

    @member = sender

    list_email.each do |email|
      mail(to: email, subject: "#{@member.fullname} invite you to join Pollios").deliver
    end

  end
end

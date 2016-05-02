class InviteFriendMailer < ActionMailer::Base
  default from: 'polliosadmin@code-app.com'

  def send_invite(member, email_list)
    email_list.each do |email|
      mail(to: email, subject: "#{member.fullname} invite you to join Pollios").deliver
    end
  end
end

class Member::InviteUser

  attr_reader :member, :email_list

  def initialize(member)
    @member = member
  end

  def by_email(email_list)
    @email_list = email_list
    process_invite_by_email
  end

  private

  def process_invite_by_email
    invite_emails = []

    email_list.each do |email|
      member.invites.where(email: email).first_or_initialize(&:save)

      invite_emails << email
    end

    nil
  end

  def send_invite_email(email_list)
    return if Rails.env.test?
    return if email_list.size == 0

    InviteFriendMailer.delay.send_invite(member, email_list)
  end

end
class InviteUser
  def initialize(member, list_email)
    @member = member
    @list_email = list_email
    @new_list_member = []
  end

  def create_list_invite
    @list_email.each do |email|
      @member.invites.where(email: email).first_or_initialize do |invite|
        invite.member_id = @member.id
        invite.email = email
        invite.save!
      end
      @new_list_member << email
    end

    send_email_list
  end

  def send_email_list
    unless Rails.env.test?
      InviteFriendMailer.delay.invite_list_email(@member, @new_list_member) if @new_list_member.size > 0
    end
  end
  
  
end
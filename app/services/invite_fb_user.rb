class InviteFbUser
  def initialize(member, list_fb_id)
    @member = member
    @list_fb_id = list_fb_id
  end

  def list_fb_id
    @list_fb_id
  end

  def member_fb_id
    @member_fb_id ||= find_member_fb_id.pluck(:id)
  end

  def invite_all
    member_fb_id.each do |friend_id|
       Friend.add_friend({
        member_id: @member.id,
        friend_id: friend_id
      })
    end
  end

  private

  def find_member_fb_id
    Member.unscoped.where(fb_id: list_fb_id)
  end
  
  
end
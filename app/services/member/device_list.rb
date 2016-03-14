class Member::DeviceList

  attr_reader :member

  def initialize(member)
    @member = member
  end

  def all_device
    Apn::Device.where(member_id: member.id).order('created_at')
  end

end
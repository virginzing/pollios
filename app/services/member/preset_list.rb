class Member::PresetList

  attr_reader :member

  def initialize(member)
    @member = member
  end 

  def presets
    all_preset
  end

  private

  def all_preset
    presets = Template.where(member_id: member.id).first
    presets.present? ? presets.poll_template : []
  end

end
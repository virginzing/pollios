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
    Template.where(member_id: member.id).first.poll_template
  end

end
class Member::PresetAction

  attr_reader :member

  def initialize(member)
    @member = member
  end

  def add(params)
    presets = Template.where(member_id: member.id).first

    presets = Template.where(member_id: member.id, poll_template: []).create! if presets.nil?
    presets.update!(poll_template: (presets.poll_template || []) << params)

    presets.poll_template
  end

  def edit(index, params)
    presets = Template.where(member_id: member.id).first
    presets.poll_template.delete_at(index)
    presets.poll_template.insert(index, params)
    presets.update!(poll_template: presets.poll_template)

    presets.poll_template
  end

  def delete(index)
    presets = Template.where(member_id: member.id).first
    presets.poll_template.delete_at(index)
    presets.update!(poll_template: presets.poll_template)

    presets.poll_template
  end

end
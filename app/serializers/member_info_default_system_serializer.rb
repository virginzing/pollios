class MemberInfoDefaultSystemSerializer < ActiveModel::Serializer

  self.root false

  attributes :member_id, :name, :avatar, :description

  def member_id
    0
  end

  def name
    "Pollios System"
  end

  def description
    "Pollios Office"
  end

  def avatar
    "http://pollios.com/images/logo/pollios.png"
  end

end


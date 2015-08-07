# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class TagSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :text

  def text
    object.name
  end
  
end

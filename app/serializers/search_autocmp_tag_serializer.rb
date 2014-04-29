class SearchAutocmpTagSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :name

  def name
    '#' + object.name
  end

end

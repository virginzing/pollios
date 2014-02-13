class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :polls, through: :taggings, source: :poll

  def self.tokens(query)
    tags = where("name like ?","%#{query}%")
    if tags.empty?
      [{id: "<<<#{query}>>>", name: "\"#{query}\""}]
    else
      tags
    end
  end

  def self.ids_from_tokens(tokens)
    tokens.gsub!(/<<<(.+?)>>>/) { create!(name: $1).id }
    tokens.split(',')
  end

end

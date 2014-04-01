class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :polls, through: :taggings, source: :poll

  has_many :poll_series_tags
  has_many :poll_series, through: :poll_series_tags, source: :poll_series

  scope :top5, 
    select("tags.*, count(taggings.tag_id) as count").
    joins(:taggings).
    group("taggings.tag_id").
    order("count desc").
    limit(5)

  def self.tokens(query)
    tags = where("name like ?","%#{query}%")
    if tags.empty?
      [{id: "<<<#{query}>>>", text: "\"#{query}\""}]
    else
      tags
    end
  end

  def self.ids_from_tokens(tokens)
    tokens.gsub!(/<<<(.+?)>>>/) { create!(name: $1).id }
    tokens.split(',')
  end

  def as_json options={}
   {
      id: id,
      text: name
   }
  end

end

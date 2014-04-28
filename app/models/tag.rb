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
      []
    else
      tags
    end
  end

  def self.ids_from_tokens(tokens)
    list_tag = []
    tokens.split(",").each do |tag_name|
      if tag_name.to_i == 0
        list_tag << Tag.find_or_create_by(name: tag_name).id
      else
        if Tag.find_by(id: tag_name.to_i).present? 
          list_tag << tag_name.to_i
        else
          list_tag << Tag.create!(name: tag_name).id
        end
      end
    end

    list_tag
  end

  def as_json options={}
   {
      id: id,
      text: name
   }
  end


end

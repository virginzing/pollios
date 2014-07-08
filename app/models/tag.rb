class Tag < ActiveRecord::Base
  include PgSearch

  pg_search_scope :searchable_name, :against => [:name],
                  :using => { 
                    :tsearch => { :prefix => true, :dictionary => "english" },
                    :trigram => { :threshold => 0.1 }
                  }

  has_many :taggings
  has_many :polls, through: :taggings, source: :poll

  has_many :poll_series_tags
  has_many :poll_series, through: :poll_series_tags, source: :poll_series

  scope :top5, -> {
    select("tags.*, count(taggings.tag_id) as count").
    joins(:taggings).
    group("taggings.tag_id").
    order("count desc").
    limit(5)
  }

  scope :search_autocmp_tags, -> (query) {
    joins("left join taggings on taggings.tag_id = tags.id").
    where("name LIKE ?", "%#{query}%"). 
    select("tags.*, count(taggings.tag_id) as count").
    group("taggings.tag_id, tags.id").
    order("count desc").
    limit(5)
  }

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

  def self.cached_tag_all
    Rails.cache.fetch('tags_all', expire_within: 30.minutes) do
      Tag.joins(:taggings).select("tags.*, count(taggings.tag_id) as count").order("count desc, name asc").group("tags.id").map(&:name).uniq.to_a
    end
  end


end

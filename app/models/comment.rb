class Comment < ActiveRecord::Base
  belongs_to :poll
  belongs_to :member

  has_many :mentions, dependent: :destroy

  has_many :member_mentionable, foreign_key: "comment_id", class_name: "Mention"
  has_many :get_member_mentionable, through: :member_mentionable, source: :mentionable

  scope :valid, -> { where(delete_status: false) }

  self.per_page = 10

  def create_mentions_list(mentioner, mentionable_list)
    mentionable_list = Member.where(id: mentionable_list)
    mentionable_list.collect{|e| mentions.create!(mentioner_id: mentioner.id, mentioner_name: mentioner.get_name, mentionable_id: e.id, mentionable_name: e.get_name) }
  end
  
end

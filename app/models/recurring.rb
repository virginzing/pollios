class Recurring < ActiveRecord::Base
  include RecurringsHelper
  belongs_to :member
  has_many :polls

  def self.re_create_poll(recurring_list)
    recurring_list.each do |rec|
      poll = rec.polls.first
      begin
        p = poll
        p.choices
        @copy = p.amoeba_dup
        @copy.save
      end
        
      # poll.tags.each do |tag|
      #   @copy.taggings.create!(tag_id: tag.id)
      # end
    end   
  end

end

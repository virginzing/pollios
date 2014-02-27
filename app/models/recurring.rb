class Recurring < ActiveRecord::Base
  include RecurringsHelper
  belongs_to :member
  has_many :polls

  # def self.re_create_poll(recurring_list)
  #   recurring_list.each do |rec|
  #     rec.polls.each do |poll|
        


  #     end
  #   end   
  # end
end

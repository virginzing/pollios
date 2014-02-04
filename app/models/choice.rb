class Choice < ActiveRecord::Base
  belongs_to :poll
  validates :answer, presence: true

  default_scope { order("id asc") }
  
  def self.create_choices(poll_id ,list_choice)
    list_choice.collect! { |answer| create(poll_id: poll_id, answer: answer) }
  end

end

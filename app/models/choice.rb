class Choice < ActiveRecord::Base
  belongs_to :poll, inverse_of: :choices
  validates :answer, presence: true

  default_scope { order("id asc") }

  amoeba do
    enable
    set [{:vote => 0}, {:vote_guest => 0}]
  end


  def self.create_choices(poll_id ,list_choice)
    list_choice.collect! { |answer| create(poll_id: poll_id, answer: answer) }
  end

  def self.query_choices(choices, expired)
    poll_id = choices[:id]
    member_id = choices[:member_id]
    voted = choices[:voted]

    if voted == "no" && !expired
      Rails.cache.fetch(['Poll', poll_id, name]) do
        find_choice(poll_id)
      end
    elsif expired
      Rails.cache.fetch(['Poll', poll_id, name]) do
        find_choice(poll_id)
      end
    else
      find_choice(poll_id)
    end
  end

  def self.find_choice(poll_id)
    where(poll_id: poll_id).to_a
  end

end

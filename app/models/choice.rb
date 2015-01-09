include GzipWithZlib
class Choice < ActiveRecord::Base
  
  belongs_to :poll
  
  validates :answer, presence: true
  validates :poll_id, presence: true
  
  default_scope { order("id asc") }

  amoeba do
    enable
    set [{:vote => 0}, {:vote_guest => 0}]
  end


  def self.create_choices(poll_id ,choices)
    # choices = decompress_zlib(choices)
    # choices.each_value { |value| create!(poll_id: poll_id, answer: value) }
    choices.collect {|e| create!(poll_id: poll_id, answer: e)}
  end

  def self.create_choices_on_web(poll_id, list_of_choice)
    puts "list choice => #{list_of_choice}"
    list_of_choice.collect {|e| create!(poll_id: poll_id, answer: e) }
  end

  def self.query_choices(choices, expired)
    poll_id = choices[:id]
    member_id = choices[:member_id]
    voted = choices[:voted]

    if voted == "no" && !expired
      find_choice(poll_id)
    elsif voted == "no" && expired
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

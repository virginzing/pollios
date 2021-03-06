# == Schema Information
#
# Table name: choices
#
#  id         :integer          not null, primary key
#  poll_id    :integer
#  answer     :string(255)
#  vote       :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#  vote_guest :integer          default(0)
#  correct    :boolean          default(FALSE)
#

include GzipWithZlib
class Choice < ActiveRecord::Base

  belongs_to :poll

  after_commit :flush_cache

  validates :answer, presence: true

  default_scope { order("id asc") }

  amoeba do
    enable
    set [{:vote => 0}, {:vote_guest => 0}]
  end

  def self.cached_find(id)
    Rails.cache.fetch([name, id]) do
      @choice = Choice.unscoped.find_by(id: id)
      raise ExceptionHandler::NotFound, "Choice not found" unless @choice.present?
      @choice
    end
  end

  def flush_cache
    Rails.cache.delete([self.class.name, id])
  end

  def self.create_choices_on_web(poll_id, list_of_choice)
    list_of_choice.collect {|e| create!(poll_id: poll_id, answer: e) }
  end

  #### deprecated ####

  # def self.create_choices(poll_id ,choices)
  #   choices.collect {|e| create!(poll_id: poll_id, answer: e)}
  # end

  #### deprecated ####

  # def self.query_choices(choices, expired)
  #   poll_id = choices[:id]
  #   member_id = choices[:member_id]
  #   voted = choices[:voted]

  #   if voted == "no" && !expired
  #     find_choice(poll_id)
  #   elsif voted == "no" && expired
  #     Rails.cache.fetch(['Poll', poll_id, name]) do
  #       find_choice(poll_id)
  #     end
  #   elsif expired
  #     Rails.cache.fetch(['Poll', poll_id, name]) do
  #       find_choice(poll_id)
  #     end
  #   else
  #     find_choice(poll_id)
  #   end
  # end

  #### deprecated ####

  # def self.find_choice(poll_id)
  #   where(poll_id: poll_id).to_a
  # end
end

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

class ChoiceSerializer < ActiveModel::Serializer
  self.root false
  
  attributes :choice_id, :answer, :vote

  def choice_id
    object.id
  end

  def answer
    object.answer
  end

  def vote
    object.vote
  end

end

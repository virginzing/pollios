class Poll < ActiveRecord::Base
  mount_uploader :photo_poll, PhotoPollUploader

  has_many :choices, dependent: :destroy
  belongs_to :member
  belongs_to :group

  def create_choices(list_choices)
    list_choices.collect { |choice| choices.create!(answer: choice) }
  end

end

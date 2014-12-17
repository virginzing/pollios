class SavePollLater < ActiveRecord::Base
  belongs_to :member
  belongs_to :savable, polymorphic: true


  def self.delete_save_later(member_id, poll_or_quetionnaire)
    find_save_later = SavePollLater.find_by(member_id: member_id, savable: poll_or_quetionnaire)
    if find_save_later.present?
      find_save_later.destroy
      true
    end
  end
end

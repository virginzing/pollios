# == Schema Information
#
# Table name: pollios_apps
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  app_id     :string(255)
#  expired_at :date
#  platform   :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#

class PolliosApp < ActiveRecord::Base

  extend Enumerize
  extend ActiveModel::Naming

  validates :name, :app_id, presence: true
  validates :app_id, uniqueness: true

  enumerize :platform, :in => { unknown: 0, ios: 1, andriod: 2 }, predicates: true, default: :unknown

  scope :un_expired, -> { where("expired_at > ? OR expired_at IS NULL", Date.current) }
  scope :usage_members, -> (app_id) { ApiToken.where(app_id: app_id) }

  def self.list_app_ids
    un_expired.map(&:app_id)
  end
end

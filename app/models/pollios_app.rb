class PolliosApp < ActiveRecord::Base

  extend Enumerize
  extend ActiveModel::Naming

  enumerize :platform, :in => { unknown: 0, ios: 1, andriod: 2 }, predicates: true, default: :unknown

  scope :un_expired, -> { where("expired_at > ? OR expired_at IS NULL", Date.current) }

  def self.list_app_ids
    un_expired.map(&:app_id)
  end
end

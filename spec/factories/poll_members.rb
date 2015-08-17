# == Schema Information
#
# Table name: poll_members
#
#  id               :integer          not null, primary key
#  member_id        :integer
#  poll_id          :integer
#  share_poll_of_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  public           :boolean
#  series           :boolean
#  expire_date      :datetime
#  in_group         :boolean          default(FALSE)
#  poll_series_id   :integer          default(0)
#

FactoryGirl.define do
  factory :poll_member do
    share_poll_of_id 0
    public false
    series false
    in_group false
    poll_series_id 0
    expire_date Time.zone.now + 1.weeks
  end

end

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

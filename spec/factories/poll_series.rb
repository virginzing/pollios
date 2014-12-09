FactoryGirl.define do
  factory :poll_series do
    description "Test Poll"
    expire_date Time.zone.now + 10.days
    member_id 1
    type_poll :binary
    type_series 1
    public true
    in_group_ids "0"
    qr_only true
  end
end

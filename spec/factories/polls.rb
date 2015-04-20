FactoryGirl.define do

  factory :poll do |f|
    f.title "Test Poll"
    f.type_poll :binary
    f.status_poll :gray
    f.in_group false
    f.public false
    f.expire_date Time.zone.now + 1.weeks
    f.expire_status false
  end


  factory :create_poll, class: Poll do
    title "ทดสอบ #eiei #nut"
    expire_within 2
    in_group false
    choices ["yes", "no"]
    type_poll "binary"
  end

  factory :create_poll_public, class: Poll do
    title "Poll Public"
    expire_within 2
    choices ["yes", "no"]
    type_poll "binary"
    is_public true
  end

end
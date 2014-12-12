FactoryGirl.define do

  factory :poll do |f|
    f.title "Test Poll"
    f.type_poll :binary
    f.status_poll :gray
  end


  factory :create_poll, class: Poll do
    title "ทดสอบ #eiei #nut"
    expire_within 2
    choices ["yes", "no"]
    type_poll "binary"
  end

  factory :create_poll_public, class: Poll do
    title "Poll Public"
    expire_within 2
    choices ["yes", "no"]
    type_poll "binary"
    is_public "1"
  end

end
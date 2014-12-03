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

end
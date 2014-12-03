FactoryGirl.define do

  factory :poll do |f|
    f.title "Test Poll"
  end


  factory :create_poll, class: Poll do
    title "ทดสอบ #eiei #nut"
    expire_within 2
    choices ["yes", "no"]
    type_poll "binary"
  end

end
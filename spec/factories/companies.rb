FactoryGirl.define do
  factory :company do
    member nil
    name "Code App"
    short_name "CA"
    using_service ["Survey"]
  end


  factory :company_admin, class: Company do
    member nil
    name "Company Admin"
    using_service ["Survey", "Feedback"]
    company_admin true
  end

end

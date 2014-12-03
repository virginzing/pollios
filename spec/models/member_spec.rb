require 'rails_helper'

RSpec.describe Member, :type => :model do
  it { should allow_value('').for(:email) }

  it { should validate_uniqueness_of(:email) }

  it { should validate_uniqueness_of(:username).on(:update) }

  it "return a member's name as a string" do
    member = create(:member, fullname: "Nutty")
    expect(member.get_name).to eq("Nutty")
  end

  it "returns array of results that match" do
    nuttapon = create(:member, fullname: "nuttapon", email: "nuttapon@code-app.com")
    ning = create(:member, fullname: "ning", email: "ning@code-app.com")
    good = create(:member, fullname: "good", email: "good@gmail.com")

    search_with_params = Member.search_member( { q: "n" })

    expect(search_with_params).to eq([ nuttapon, ning])
  end

end

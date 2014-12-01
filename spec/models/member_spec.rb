# require 'rails_helper'

# RSpec.describe Member, :type => :model do
#   describe Member do

#     it "return a member's name as a string" do
#       member = create(:member, fullname: "Nutty")
#       expect(member.get_name).not_to eq("Nuttyz")
#     end

#     it "returns array of results that match" do
#       nuttapon = create(:member, email: "nuttapon@code-app.com")
#       ning = create(:member, email: "ning@code-app.com")
#       good = create(:member, email: "good@gmail.com")

#       expect( Member.search_member( { q: "n" }) ).to eq([nuttapon, ning])
#     end
#   end
# end

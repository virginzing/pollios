require 'rails_helper'

RSpec.describe Member, :type => :model do

  it { should allow_value('').for(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:username).on(:update) }

  it { should enumerize(:member_type).in(:citizen, :celebrity, :brand, :company).with_default(:citizen) }

  it { should have_many(:un_see_polls) }

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

  describe "#citizen?" do
    let(:member) { create(:member) }

    context 'when member_type is citizen' do
      it "should return true" do
        member.member_type = :citizen
        expect(member.citizen?).to eq(true)
      end
    end
  end

  describe ".get_recent_activity" do
    let!(:member) { create(:member) }
    let!(:poll) { create(:poll, member: member, public: true) }


    it "return 3 recent activity" do
      10.times do
        Activity.create_activity_poll(member, poll, 'Vote')
      end

      expect(member.get_recent_activity.size).to eq(3)
    end
  end


  describe "InviteFbUser" do
    let!(:member) {  create(:member, fullname: "Nutty", email: Faker::Internet.email) }
    let!(:member_sync_one) { create(:member, fullname: "Nutty Sync Facebook", email: Faker::Internet.email, fb_id: "1111") }
    let!(:member_sync_two) { create(:member, fullname: "Mekumi Sync Facebook", email: Faker::Internet.email, fb_id: "2222") }

    it "have 3 membes" do
      expect(Member.count).to eq(3)
    end

    it "can invite friends" do
      init_invite_fb_user = InviteFbUser.new(member, ["1111", "2222"])

      expect(init_invite_fb_user.list_fb_id).to eq(["1111", "2222"])

      expect(init_invite_fb_user.member_fb_id).to eq([member_sync_one.id, member_sync_two.id])

      init_invite_fb_user.invite_all
      
      expect(Friend.count).to eq(4)

      find_member_with_member_sync_one = Friend.find_by(follower: member, followed: member_sync_one, status: 0)

      expect(find_member_with_member_sync_one.present?).to be true
    end
  end

  describe ".get_ban_members" do
    let!(:member_one) { create(:member, fullname: "Ban Member 1", email: "ban_member_one@pollios.com", status_account: :ban) }
    let!(:member_two) { create(:member, fullname: "Ban Member 2", email: "ban_member_two@pollios.com", status_account: :ban) }

    it "have 2 members in list ban members" do
      expect(Admin::BanMember.get_member_ids.length).to eq(2)
    end
  end

end

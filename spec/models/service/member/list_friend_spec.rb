require 'rails_helper'

RSpec.describe "Member List Friend" do
  let!(:member) { create(:member, fullname: "Nutty", email: "nutty@gmail.com") }

  let!(:friend) { create(:member, fullname: "Mickey", email: "mickey@gmail.com") }

  describe "#active" do
    
    before do
      @init_list_friend_of_member = Member::ListFriend.new(member)
    end

    it "has zero friend's active" do
      expect(@init_list_friend_of_member.active.to_a.size).to eq(0)
    end

    it "has one friend's active" do
      create(:friend, follower: member, followed: friend, active: true, status: 1, following: false)
      create(:friend, follower: friend, followed: member, active: true, status: 1, following: false)

      expect(@init_list_friend_of_member.active.to_a.size).to eq(1)
    end
  end

  describe "#block" do
    before do
      @init_list_friend_of_member = Member::ListFriend.new(member)
    end

    it "has zero friend's blck" do
      expect(@init_list_friend_of_member.block.to_a.size).to eq(0)
    end

    it "has one friend's block" do
      create(:friend, follower: member, followed: friend, block: true, active: true, status: 1)
      expect(@init_list_friend_of_member.block.to_a.size).to eq(1)
    end

  end

  describe "#your_request" do
    before do
      @init_list_friend_of_member = Member::ListFriend.new(member)
    end

    it "has zero friend's your request" do
      expect(@init_list_friend_of_member.your_request.to_a.size).to eq(0)
    end

    it "has one friend's your request" do
      create(:friend, follower: member, followed: friend, status: 0)
      expect(@init_list_friend_of_member.your_request.to_a.size).to eq(1)
    end

  end


  describe "#friend_request" do
    before do 
      @init_list_friend_of_member = Member::ListFriend.new(member)
    end

    it "has zero friend's request" do
      expect(@init_list_friend_of_member.friend_request.to_a.size).to eq(0)
    end

    it "has one friend's request" do
      create(:friend, follower: member, followed: friend, status: 2)
      expect(@init_list_friend_of_member.friend_request.to_a.size).to eq(1)
    end
  end

end
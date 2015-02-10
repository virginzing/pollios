require 'rails_helper'

RSpec.describe "Search" do

  let!(:member) { create(:member) }

  describe "GET /searchs/user_and_group" do
    context "search group" do

      before do
        get "/searchs/user_and_group.json", { member_id: member.id }
      end

      it "find group by group id" do
        
      end

      it "find group by group name" do
        
      end
    end


    context "search user" do
      it "find user by public id" do
        
      end

      it "find user by fullname" do
        
      end

    end
  end


end
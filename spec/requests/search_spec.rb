require 'rails_helper'

RSpec.describe "Search" do

  let!(:member) { create(:member) }

  describe "GET /searches/users_and_groups" do
    context "search group" do

      before do
        create(:member, fullname: "Nutty", email: "nutty@info.com")
        create(:group, name: "Code App", public_id: "codeapp", public: true)
      end

      it "find group by group id" do
         get "/searches/users_and_groups.json", { member_id: member.id, search: "codeapp" }, { "Accept" => "application/json" }

         expect(response).to be_success
         expect(json["response_status"]).to eq("OK")
         expect(json["list_groups"].present?).to be true
      end

      it "find group by group name" do
        get "/searches/users_and_groups.json", { member_id: member.id, search: "Code App" }, { "Accept" => "application/json" }
        
        expect(response).to be_success
        expect(json["response_status"]).to eq("OK")
        expect(json["list_groups"].present?).to be true
      end
    end


    context "search user" do
      before do
        create(:member, fullname: "Nutty", email: "nutty@info.com", public_id: "07510509")
        create(:member, fullname: "Mekumi", email: "mekumi@info.com", public_id: "mekumi_kiku")
      end

      it "find user by public id" do
        get "/searches/users_and_groups.json", { member_id: member.id, search: "mekumi_kiku" }, { "Accept" => "application/json" }

        expect(response).to be_success
        expect(json["response_status"]).to eq("OK")
        expect(json["list_members"].present?).to be true
      end

      it "find user by fullname" do
        get "/searches/users_and_groups.json", { member_id: member.id, search: "Nutty" }, { "Accept" => "application/json" }
        expect(response).to be_success
        expect(json["response_status"]).to eq("OK")
        expect(json["list_members"].present?).to be true
      end

    end

    context "return result of user and group" do
      before do
        create(:member, fullname: "Nutty", email: "nutty@info.com", public_id: "07510509")
        create(:member, fullname: "Mekumi", email: "mekumi@info.com", public_id: "mekumi_kiku")
        create(:group, name: "Code App", public_id: "codeapp", public: true)
        create(:group, name: "Nutty Fanclub", public_id: "nutty_fanclub", public: true)
      end

      it "get user and also group list" do
        get "/searches/users_and_groups.json", { member_id: member.id, search: "Nutty" }, { "Accept" => "application/json" }

        expect(response).to be_success
        expect(json["response_status"]).to eq("OK")
        expect(json["list_members"].present?).to be true
        expect(json["list_groups"].present?).to be_true
      end
    end
  end


end
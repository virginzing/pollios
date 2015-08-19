require 'rails_helper'

RSpec.describe "Search" do
  let!(:member) { create(:member, fullname: "Nutty") }
  let(:member_two) { create(:member, fullname: "Nutty agian", email: "nutagain@gmail.com") }

  let!(:group) { create(:group, name: "Nut Group", public: true) }

  let!(:group_member) { create(:group_member, group: group, member: member, active: true) }

  describe "GET /searches/users_and_groups" do

    it "find group by group name" do
      get "/searches/users_and_groups.json", { member_id: member.id, search: "Nut" }, { "Accept" => "application/json" }

      expect(response).to be_success
      expect(json["response_status"]).to eq("OK")
      expect(json["list_groups"].count).to eq(1)
    end

    context "search user" do
      before do
        create(:member, fullname: "Nutty", email: "nutty@info.com", public_id: "07510509", first_signup: false)
        create(:member, fullname: "Mekumi", email: "mekumi@info.com", public_id: "mekumi_kiku", first_signup: false)
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

      let!(:member) { create(:member, fullname: "Nutty", public_id: "nutty_fanclub", first_signup: false) }
      let!(:group) { create(:group, name: "Nutty Group fanclub", public: true) }
      let!(:group_member) { create(:group_member, group: group, member: member, active: true) }

      it "get user and also group list" do
        get "/searches/users_and_groups.json", { member_id: member.id, search: "fanclub" }, { "Accept" => "application/json" }

        expect(response).to be_success
        expect(json["response_status"]).to eq("OK")
        expect(json["list_members"].present?).to be true
        expect(json["list_groups"].present?).to be true
      end
    end
  end

  describe "POST /searches/clear_search_users_and_groups" do

    before do
      TypeSearch.delete_all
      TypeSearch.create_log_search_users_and_groups(member_two, "Nuttapon")
      TypeSearch.create_log_search_users_and_groups(member_two, "Nutty")
    end

    it "success" do
      post "/searches/clear_search_users_and_groups.json", { member_id: member_two.id }, { "Accept" => "application/json" }
      expect(response.status).to eq(201)
    end

    it "clear key of users_and_groups to empty" do
      p TypeSearch.find_search_users_and_groups(member_two)
      expect(TypeSearch.find_search_users_and_groups(member_two).count).to eq(2)
      post "/searches/clear_search_users_and_groups.json", { member_id: member_two.id }, { "Accept" => "application/json" }
      p TypeSearch.find_search_users_and_groups(member_two)
      expect(TypeSearch.find_search_users_and_groups(member_two).count).to eq(0)
    end

  end

  describe "POST /searches/clear_search_tags" do

    it "success" do
      post "/searches/clear_search_tags.json", { member_id: member.id }, { "Accept" => "application/json" }
      expect(response.status).to eq(201)
    end

    it "clear key of users_and_groups to empty" do
      TypeSearch.create_log_search_tags(member, "Sport")
      TypeSearch.create_log_search_tags(member, "KantaiCollection")

      expect(TypeSearch.find_search_tags(member).count).to eq(2)

      post "/searches/clear_search_tags.json", { member_id: member.id }, { "Accept" => "application/json" }

      expect(TypeSearch.find_search_tags(member).count).to eq(0)

    end

  end



end

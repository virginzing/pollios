# == Schema Information
#
# Table name: access_webs
#
#  id              :integer          not null, primary key
#  member_id       :integer
#  accessable_id   :integer
#  accessable_type :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

RSpec.describe AccessWeb, :type => :model do

  let!(:member) {  create(:member) }
  let!(:company) { create(:company, member: member) }

  describe ".with_company" do
    let!(:access_web)  { create(:access_web, member: member, accessable: company) }

    it "access to company panel" do
      expect(AccessWeb.with_company(member.id).present?).to be true
    end
  end
end

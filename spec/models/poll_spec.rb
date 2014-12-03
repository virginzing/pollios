require 'rails_helper'

RSpec.describe Poll, :type => :model do
  it { should validate_presence_of(:member_id) }
  it { should validate_presence_of(:title) }
  it { should have_many(:choices) }


  describe ".create_poll" do
    let!(:ex_member) { create(:member) }

    it "return detail of poll" do
      poll, error_message = Poll.create_poll( FactoryGirl.attributes_for(:create_poll).merge(member_id: ex_member.id), ex_member)

      # tag_count = Tag.all.count

      expect(poll).to eq(poll) 

      # puts "poll => #{poll}"
      # puts "error_message => #{error_message}"
    end
  end

  it "is titled new_poll" do
    poll = Poll.new(title: "new_poll")
    expect(poll.title).to eq("new_poll")
  end

  it "[1,2,3] include 1" do
    expect([1,2,3]).to include(1)
  end

  it "has none to begin with" do
    expect(Poll.count).to eq(0)
  end

  it "has one after adding one" do
    member = create(:member)
    create(:poll, member_id: member.id)
    expect(Poll.count).to eq(1)
  end
end

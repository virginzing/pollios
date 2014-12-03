require 'rails_helper'

RSpec.describe Poll, :type => :model do
  it { should validate_presence_of(:member_id) }
  it { should validate_presence_of(:title) }
  it { should have_many(:choices) }

  let!(:member) { create(:member, email: "test@gmail.com") }

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
    create(:poll, member_id: member.id)
    expect(Poll.count).to eq(1)
  end

  describe "#get_vote_max" do
    let!(:poll) { create(:poll, member_id: member.id) }

    let!(:choice1) { create(:choice, poll: poll, vote: 10 ) }
    let!(:choice2) { create(:choice, poll: poll, vote: 20 ) }
    let!(:choice3) { create(:choice, poll: poll, vote: 30 ) }

    it "return two from most the vote of choice at descending as json format" do
      choice_hash = [{
        "answer" => choice3.answer,
        "vote" => choice3.vote,
        "choice_id" => choice3.id
      },
      {
        "answer" => choice2.answer,
        "vote" => choice2.vote,
        "choice_id" => choice2.id
      }]

      expect(poll.get_vote_max).to eq(choice_hash)
    end

    it "return have type of array and two element" do
      expect(poll.get_vote_max).to be_a(Array)
      expect(poll.get_vote_max.count).to eq(2)
    end

  end

end

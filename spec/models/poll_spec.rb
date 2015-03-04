require 'rails_helper'

RSpec.describe Poll, :type => :model do
  it { should validate_presence_of(:member_id) }
  it { should validate_presence_of(:title) }
  it { should have_many(:choices) }
  it { should have_many(:un_see_polls) }
  it { should have_many(:save_poll_laters) }

  it { should have_many(:poll_attachments) }
  
  let!(:member) { create(:member, email: "test@gmail.com") }

  describe ".create_poll" do
    let!(:ex_member) { create(:member) }

    it "return detail of poll" do
      poll, error_message = Poll.create_poll( FactoryGirl.attributes_for(:create_poll).merge(member_id: ex_member.id), ex_member)

      # tag_count = Tag.all.count

      expect(poll).to eq(poll) 

      expect(poll.qrcode_key.length).to eq(8)
      # puts "poll => #{poll}"
      # puts "error_message => #{error_message}"
    end
  end

  it "return notify_state is idle when new poll" do
    new_poll = Poll.new
    expect(new_poll).to be_idle
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

    let!(:choice1) { create(:choice, poll: poll, answer: "1", vote: 10 ) }
    let!(:choice2) { create(:choice, poll: poll, answer: "2", vote: 20 ) }
    let!(:choice3) { create(:choice, poll: poll, answer: "3", vote: 30 ) }

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

  describe "#get_choice_detail" do

    let!(:poll) { create(:poll, member_id: member.id) }
    let!(:choice1) { create(:choice, poll: poll, answer: "1", vote: 10 ) }
    let!(:choice2) { create(:choice, poll: poll, answer: "2", vote: 20 ) }

    it "sends a list of choice as json format" do
      mock_choice = []

      poll.reload.choices.each do |choice|
        mock_choice << { "choice_id" => choice.id, "answer" => choice.answer, "vote" => choice.vote }
      end

      expect(poll.get_choice_detail).to eq(mock_choice)
    end
  end

  describe ".check_type_of_choice" do
    let!(:choice_list) { ["A", "B", "C"] }
    let!(:choice_list_string) { "A,B,C" }

    it "return same choice_list" do
      expect(Poll.check_type_of_choice(choice_list)).to eq(choice_list)
    end

    it "split string by (,) and return arraoy of choice_list" do
      expect(Poll.check_type_of_choice(choice_list_string)).to eq(choice_list)
    end
  end

  describe "#vote_poll" do
    let!(:poll) { create(:poll, member_id: member.id) }

    let!(:choice1) { create(:choice, poll: poll, answer: "1", vote: 10 ) }
    let!(:choice2) { create(:choice, poll: poll, answer: "2", vote: 20 ) }
    let!(:choice3) { create(:choice, poll: poll, answer: "3", vote: 30 ) }
    
    let!(:member_one) { create(:member, fullname: "member_one") }

    before do
      Poll.vote_poll({ id: poll.id, member_id: member_one.id, choice_id: choice1.id}, member_one, {})
    end

    it "return notify_state is process" do
      expect(poll.reload.notify_state).to be_process
    end

    it "return vote_all is 1" do
      expect(poll.reload.vote_all).to eq(1)
    end

    it "create to history vote record" do
      expect(HistoryVote.count).to eq(1)
    end

    it "return notify_state_at is time now" do
      expect(poll.reload.notify_state_at.present?).to be true
    end
  end

end

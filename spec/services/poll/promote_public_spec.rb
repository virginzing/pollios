require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\nPoll::PromotePublic" do
    let(:member) { create(:member, fullname: Faker::Name.name, email: Faker::Internet.email)}
    let(:poll) { create(:poll, member: member) }

    context "A user with remaining points promoting his poll to public" do
        
    end
end
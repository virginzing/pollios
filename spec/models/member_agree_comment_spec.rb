require 'rails_helper'

RSpec.describe MemberAgreeComment, type: :model do

  it { should belong_to(:member) }

  it { should belong_to(:comment) }
end

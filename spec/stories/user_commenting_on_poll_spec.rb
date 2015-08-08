require 'rails_helper'

pathname = Pathname.new(__FILE__)
puts "[FILE] #{pathname.dirname.basename}/#{pathname.basename}"

RSpec.describe "[Story] User commenting on a poll" do
    context "A user commenting on a poll not allowing comment" do
    end

    context "A user commenting on a poll allowing comment" do
    end
end
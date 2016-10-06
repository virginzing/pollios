require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\nNotification::Group::Join" do

  context 'Given a group with some members,' do
    before(:all) do
      @group = create(:group_with_members)
    end

    specify 'everyone in the group can be notified if someone join the group.' do
      @group_members = Group::MemberList.new(@group).active
      @some_member = create(:member)

      Notification::Group::Join.new(@some_member, @group)

      @latest_notifications = NotifyLog \
                              .where(recipient: @group_members) \
                              .order(updated_at: :desc) \
                              .group_by(&:recipient_id) \
                              .map { |pair| pair[1][0] }

      expect(@latest_notifications.size).to be @group_members.size
      expect(@latest_notifications.map(&:message)).to all include "#{@some_member.fullname} joined in #{@group.name} group."
      expect(@latest_notifications.map(&:sender)).to all eq @some_member
    end

  end
  
end

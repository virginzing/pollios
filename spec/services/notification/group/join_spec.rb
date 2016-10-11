require 'rails_helper'

pathname = Pathname.new(__FILE__)
RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\nNotification::Group::Join" do

  context 'Given a group with some members and a member not in group,' do
    before(:all) do
      @group = create(:group_with_members)
      @some_member = create(:member)
    end

    specify 'everyone in the group can be notified if someone join the group.' do
      @group_members = Group::MemberList.new(@group).active

      Notification::Group::Join.new(@some_member, @group)

      @latest_notification_logs = NotifyLog.where(recipient: @group_members).latest

      expect(@latest_notification_logs.size).to be @group_members.size
      expect(@latest_notification_logs.map(&:message)).to all include "#{@some_member.fullname} joined in #{@group.name} group."
      expect(@latest_notification_logs.map(&:sender)).to all eq @some_member

      @devices = @group_members.map(&:apn_devices).flatten
      @device_tokens = @devices.map(&:token).map { |token| token.gsub(/\s+/, '') }

      @latest_notification_pushes = Rpush::Apns::Notification
                                    .where(device_token: @device_tokens)
                                    .order(updated_at: :desc)
                                    .group_by(&:device_token)
                                    .map { |pair| pair[1][0] }

      expect(@latest_notification_pushes.size).to be @devices.size

      expect(@latest_notification_pushes.map { |push| push.data['group_id'] }).to all eq @group.id
      expect(@latest_notification_pushes.map(&:alert)).to all include "#{@some_member.fullname} joined in #{@group.name} group."
    end

    context 'given some more members in group with join_group notification off,' do
      before(:all) do
        @disabled_notification_members = create_list(:member_in_groups, 3, :custom_notification, join_group_notification: false, groups: [@group])
      end

      specify 'members in group with join_group notification off cannot be notified if someone join the group.' do
        Notification::Group::Join.new(@some_member, @group)

        @devices = @disabled_notification_members.map(&:apn_devices).flatten
        @device_tokens = @devices.map(&:token).map { |token| token.gsub(/\s+/, '') }

        @latest_notification_pushes = Rpush::Apns::Notification
                                      .where(device_token: @device_tokens)
                                      .order(updated_at: :desc)
                                      .group_by(&:device_token)
                                      .map { |pair| pair[1][0] }

        expect(@latest_notification_pushes.map(&:alert)).to all eq nil
      end
    end

  end
  
end

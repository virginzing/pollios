# require 'rails_helper'

# pathname = Pathname.new(__FILE__)
# RSpec.describe "[Service: #{pathname.dirname.basename}/#{pathname.basename}]\n\n Buyer::AddressAction" do

#   context '#create: A buyer adds new address.' do
#     before(:context) do
#       @buyer = create(:buyer)
#       @address_params = attributes_for(:address)

#       @new_address = Buyer::AddressAction.new(@buyer).create(@address_params)
#     end

#     it '- The buyer can create the address.' do
#       expect(@new_address).to be_valid
#     end

#     it '- The address is created according to the action.' do
#       expect(Buyer::AddressList.new(@buyer).all.find(@new_address.id)).to eq @new_address
#     end
#   end

#   context '#create: A buyer adds new address with name which is conflicted with existing address.' do
#     before(:context) do
#       @buyer_with_addresses = create(:buyer_with_addresses)
#       @address = Buyer::AddressList.new(@buyer_with_addresses).all.order('RANDOM()').first
#       @address_params = attributes_for(:address, name: @address.name)
#     end

#     it '- The action guard fails with address_name_already_exists_message.' do
#       expect { Buyer::AddressAction.new(@buyer_with_addresses).create(@address_params) } \
#         .to raise_error(address_name_already_exists_message(@address.name))
#     end
#   end

#   context '#edit: A buyer edits his address.' do
#     before(:context) do
#       @buyer_with_addresses = create(:buyer_with_addresses)
#       @address = Buyer::AddressList.new(@buyer_with_addresses).all.first
#       @address_params = attributes_for(:address)

#       @edited_address = Buyer::AddressAction.new(@buyer_with_addresses, @address).edit(@address_params)
#     end

#     it '- The buyer can edit the address.' do
#       expect(@edited_address).to be_valid
#     end

#     it '- The address is edited according to the action.' do
#       expect(Buyer::AddressList.new(@buyer_with_addresses).all.find(@edited_address.id)).to eq @edited_address
#     end
#   end

#   context '#edit: A buyer edits non-existing address.' do
#     before(:context) do
#       @buyer_with_addresses = create(:buyer_with_addresses)
#       @address = Buyer::AddressList.new(@buyer_with_addresses).all.first
#       @address_params = @address.attributes

#       Buyer::AddressAction.new(@buyer_with_addresses, @address).delete
#     end

#     it '- The action guard fails with address_not_exist_message.' do
#       expect { Buyer::AddressAction.new(@buyer_with_addresses, @address).edit(@address_params) } \
#         .to raise_error(address_not_exist_message)
#     end
#   end

#   context '#edit: A buyer edits his address with name which is conflicted with existing address.' do
#     before(:context) do
#       @buyer_with_addresses = create(:buyer_with_addresses, address_count: 2)
#       @address_1 = Buyer::AddressList.new(@buyer_with_addresses).all.first
#       @address_2 = Buyer::AddressList.new(@buyer_with_addresses).all.second
#       @address_2_name_params = {name: @address_2.name}
#     end

#     it '- The action guard fails with address_name_already_exists_message.' do
#       expect { Buyer::AddressAction.new(@buyer_with_addresses, @address_1).edit(@address_2_name_params) } \
#         .to raise_error(address_name_already_exists_message(@address_2.name))
#     end
#   end

#   context '#delete: A buyer deletes his address.' do
#     before(:context) do
#       @buyer_with_addresses = create(:buyer_with_addresses)
#       @address = Buyer::AddressList.new(@buyer_with_addresses).all.first

#       @deleted_address = Buyer::AddressAction.new(@buyer_with_addresses, @address).delete
#     end

#     it '- The buyer can delete the product.' do
#       expect(@deleted_address).not_to be_nil
#     end

#     it '- The product is deleted according to the action.' do
#       expect(Buyer::AddressList.new(@buyer_with_addresses).all.exists?(@deleted_address.id)).to be false
#     end
#   end

#   context '#delete: A buyer deletes non-existing address.' do
#     before(:context) do
#       @buyer_with_addresses = create(:buyer_with_addresses)
#       @address = Buyer::AddressList.new(@buyer_with_addresses).all.first

#       Buyer::AddressAction.new(@buyer_with_addresses, @address).delete
#     end

#     it '- The action guard fails with address_not_exist_message.' do
#       expect {Buyer::AddressAction.new(@buyer_with_addresses, @address).delete} \
#         .to raise_error(address_not_exist_message)
#     end
#   end
# end

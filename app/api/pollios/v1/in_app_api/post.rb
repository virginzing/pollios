module Pollios::V1::InAppAPI
  class Post < Grape::API
    version 'v1', using: :path
    
    resource :in_app do
      resource :purchases do
        helpers do
          def member_in_app_purchase
            @member_in_app_purchase ||= Member::InAppPurchase.new(current_member, params[:receipt][:in_app])
          end
        end

        desc 'in-app purchase'
        params do
          requires :receipt, type: Hash, desc: 'receipt data' do
            requires :in_app, type: Array, desc: 'receipt in-app data' do
              requires :transaction_id, type: String, desc: 'transaction id'
              requires :product_id, type: String, desc: 'product id'
              requires :purchase_date, type: String, desc: 'purchase date'
            end
          end
        end
        post do
          member_in_app_purchase.activate
        end
      end
    end
    
  end
end

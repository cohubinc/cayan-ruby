require 'savon'

module Cayan
  module Merchantware
    module Credit
      class Client
        @client = nil
        attr_accessor :merchant_name, :merchant_site_id, :merchant_key

        def initialize(merchant_name:, merchant_site_id:, merchant_key:)
          @merchant_name = merchant_name
          @merchant_site_id = merchant_site_id
          @merchant_key = merchant_key

          @client = Savon.client(
            wsdl: 'https://ps1.merchantware.net/Merchantware/ws/RetailTransaction/v45/Credit.asmx?WSDL',
            convert_request_keys_to: :camelcase
          )
        end

        def with_credentials(hash)
          hash.merge({
            credentials: {
              merchant_name: @merchant_name,
              merchant_site_id: @merchant_site_id,
              merchant_key: @merchant_key,
            }
          })
        end

        def board_card(payment_data:)
          response = @client.call(:board_card, message: with_credentials({
            payment_data: payment_data
          }))

          response.body[:board_card_response][:board_card_result]
        end

        def find_boarded_card(token:)
          response = @client.call(:find_boarded_card, message: with_credentials({
            request: {
              vault_token: token
            }
          }))
          
          response.body[:find_boarded_card_response][:find_boarded_card_result]
        end
        
        def adjust_tip(token:, amount:)
          response = @client.call(:adjust_tip, message: with_credentials({
            request: {
              token: token,
              amount: amount
            }
          }))
          
          response.body[:adjust_tip_response][:adjust_tip_result]
        end

        def attach_signature(token:, vector_image_data:)
          response = @client.call(:attach_signature, message: with_credentials({
            request: {
              token: token,
              vector_image_data: vector_image_data
            }
          }))
          
          response.body[:attach_signature_response][:attach_signature_result]
        end

        def authorize(payment_data:, amount:, invoice_number: nil, register_number: nil, merchant_transaction_id: nil, card_acceptor_terminal_id: nil)
          response = @client.call(:authorize, message: with_credentials({
            payment_data: payment_data,
            request: {
              amount: amount,
              invoice_number: invoice_number,
              register_number: register_number,
              merchant_transaction_id: merchant_transaction_id,
              card_acceptor_terminal_id: card_acceptor_terminal_id
            }
          }))
          
          response.body[:authorize_response][:authorize_result]
        end

        def capture(token:, amount:, invoice_number: nil, register_number: nil, merchant_transaction_id: nil, card_acceptor_terminal_id: nil)
          response = @client.call(:capture, message: with_credentials({
            request: {
              token: token,
              amount: amount,
              invoice_number: invoice_number,
              register_number: register_number,
              merchant_transaction_id: merchant_transaction_id,
              card_acceptor_terminal_id: card_acceptor_terminal_id
            }
          }))
          
          response.body[:capture_response][:capture_result]
        end

        def update_boarded_card(token:, expiration_date:)
          response = @client.call(:update_boarded_card, message: with_credentials({
            request: {
              token: token,
              expiration_date: expiration_date
            }
          }))
          
          response.body[:update_boarded_card_response][:update_boarded_card_result]
        end

        def force_capture(payment_data:, amount:, authorization_code:, invoice_number: nil, register_number: nil, merchant_transaction_id: nil, card_acceptor_terminal_id: nil, ecommerce_transaction_indicator: nil)
          response = @client.call(:force_capture, message: with_credentials({
            payment_data: payment_data,
            request: {
              amount: amount,
              authorization_code: authorization_code,
              invoice_number: invoice_number,
              register_number: register_number,
              merchant_transaction_id: merchant_transaction_id,
              card_acceptor_terminal_id: card_acceptor_terminal_id,
              ecommerce_transaction_indicator: ecommerce_transaction_indicator
            }
          }))
          
          response.body[:force_capture_response][:force_capture_result]
        end
        
        def refund(payment_data:, amount:, invoice_number: nil, register_number: nil, merchant_transaction_id: nil, card_acceptor_terminal_id: nil, ecommerce_transaction_indicator: nil)
          response = @client.call(:refund, message: with_credentials({
            payment_data: payment_data,
            request: {
              amount: amount,
              invoice_number: invoice_number,
              register_number: register_number,
              merchant_transaction_id: merchant_transaction_id,
              card_acceptor_terminal_id: card_acceptor_terminal_id,
              ecommerce_transaction_indicator: ecommerce_transaction_indicator
            }
          }))

          response.body[:refund_response][:refund_result]
        end

        def sale(payment_data:, amount: nil, cashback_amount: nil, surcharge_amount: nil, tax_amount: nil, health_care_amount_details: nil, invoice_number: nil, purchase_order_number: nil, customer_code: nil, register_number: nil, merchant_transaction_id: nil, card_acceptor_terminal_id: nil, enable_partial_authorization: nil, force_duplicate: nil, ecommerce_transaction_indicator: nil)
          response = @client.call(:sale, message: with_credentials({
            payment_data: payment_data,
            request: {
              amount: amount,
              cashback_amount: cashback_amount,
              surcharge_amount: surcharge_amount,
              tax_amount: tax_amount,
              health_care_amount_details: health_care_amount_details,
              invoice_number: invoice_number,
              purchase_order_number: purchase_order_number,
              customer_code: customer_code,
              register_number: register_number,
              merchant_transaction_id: merchant_transaction_id,
              card_acceptor_terminal_id: card_acceptor_terminal_id,
              enable_partial_authorization: enable_partial_authorization,
              force_duplicate: force_duplicate,
              ecommerce_transaction_indicator: ecommerce_transaction_indicator
            }
          }))

          response.body[:sale_response][:sale_result]
        end

        def settle_batch
          response = @client.call(:settle_batch, message: with_credentials({}))

          response.body[:settle_batch_response][:settle_batch_result]
        end

        def unboard_card(token:)
          response = @client.call(:unboard_card, message: with_credentials({
            request: {
              vault_token: token
            }
          }))

          response.body[:unboard_card_response][:unboard_card_result]
        end

        def void(token:, register_number: nil, merchant_transaction_id: nil, card_acceptor_terminal_id: nil)
          response = @client.call(:void, message: with_credentials({
            request: {
              token: token,
              register_number: register_number,
              merchant_transaction_id: merchant_transaction_id,
              card_acceptor_terminal_id: card_acceptor_terminal_id
            }
          }))

          response.body[:void_response][:void_result]
        end
      end
    end
  end
end
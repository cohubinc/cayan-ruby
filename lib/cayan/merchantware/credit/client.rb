require 'savon'

module Cayan
  module Merchantware
    module Credit
      class Client
        @client = nil
        attr_accessor :credentials

        def initialize(credentials)
          @credentials = credentials
          @client = Savon.client(
            wsdl: 'https://ps1.merchantware.net/Merchantware/ws/RetailTransaction/v45/Credit.asmx?WSDL',
            convert_request_keys_to: :camelcase
          )
        end

        def with_credentials(hash)
          hash.merge({
            credentials: credentials
          })
        end

        def board_card(payment_data)
          response = @client.call(:board_card, message: with_credentials({
            payment_data: payment_data
          }))

          response.body[:board_card_response][:board_card_result]
        end

        def find_boarded_card(vault_token_request)
          response = @client.call(:find_boarded_card, message: with_credentials({
            request: vault_token_request
          }))
          
          response.body[:find_boarded_card_response][:find_boarded_card_result]
        end
        
        def adjust_tip(tip_request)
          response = @client.call(:adjust_tip, message: with_credentials({
            request: tip_request
          }))
          
          response.body[:adjust_tip_response][:adjust_tip_result]
        end

        def attach_signature(signature_request)
          response = @client.call(:attach_signature, message: with_credentials({
            request: signature_request
          }))
          
          response.body[:attach_signature_response][:attach_signature_result]
        end

        def authorize(payment_data, authorization_request)
          response = @client.call(:authorize, message: with_credentials({
            payment_data: payment_data,
            request: authorization_request
          }))
          
          response.body[:authorize_response][:authorize_result]
        end

        def capture(capture_request)
          response = @client.call(:capture, message: with_credentials({
            request: capture_request
          }))
          
          response.body[:capture_response][:capture_result]
        end

        def update_boarded_card(update_boarded_card_request)
          response = @client.call(:update_boarded_card, message: with_credentials({
            request: update_boarded_card_request
          }))
          
          response.body[:update_boarded_card_response][:update_boarded_card_result]
        end

        def force_capture(payment_data, force_capture_request)
          response = @client.call(:force_capture, message: with_credentials({
            payment_data: payment_data,
            request: force_capture_request
          }))
          
          response.body[:force_capture_response][:force_capture_result]
        end
        
        def refund(payment_data, refund_request)
          response = @client.call(:refund, message: with_credentials({
            payment_data: payment_data,
            request: refund_request
          }))

          response.body[:refund_response][:refund_result]
        end

        def sale(payment_data, sale_request)
          response = @client.call(:sale, message: with_credentials({
            payment_data: payment_data,
            request: sale_request
          }))

          response.body[:sale_response][:sale_result]
        end

        def settle_batch
          response = @client.call(:settle_batch, message: with_credentials({}))

          response.body[:settle_batch_response][:settle_batch_result]
        end

        def unboard_card(vault_token_request)
          response = @client.call(:unboard_card, message: with_credentials({
            request: vault_token_request
          }))

          response.body[:unboard_card_response][:unboard_card_result]
        end

        def void(void_request)
          response = @client.call(:void, message: with_credentials({
            request: void_request
          }))

          response.body[:void_response][:void_result]
        end
      end
    end
  end
end
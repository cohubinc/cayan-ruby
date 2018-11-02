require 'savon'

module Cayan
  module Merchantware
    module GiftCard
      class Client
        @client = nil
        attr_accessor :credentials

        def initialize(credentials)
          @credentials = credentials
          @client = Savon.client(
            wsdl: 'https://ps1.merchantware.net/Merchantware/ws/ExtensionServices/v45/Giftcard.asmx?WSDL',
            convert_request_keys_to: :camelcase
          )
        end

        def with_credentials(hash)
          hash.merge({
            credentials: credentials
          })
        end

        def activate_card(payment_data, request)
          response = @client.call(:activate_card, message: with_credentials({
            payment_data: payment_data,
            request: request
          }))

          response.body[:activate_card_response][:activate_card_result]
        end

        def add_points(payment_data, request)
          response = @client.call(:add_points, message: with_credentials({
            payment_data: payment_data,
            request: request
          }))

          response.body[:add_points_response][:add_points_result]
        end

        def add_value(payment_data, request)
          response = @client.call(:add_value, message: with_credentials({
            payment_data: payment_data,
            request: request
          }))

          response.body[:add_value_response][:add_value_result]
        end

        def balance_inquiry(payment_data, request)
          response = @client.call(:balance_inquiry, message: with_credentials({
            payment_data: payment_data,
            request: request
          }))

          response.body[:balance_inquiry_response][:balance_inquiry_result]
        end

        def refund(payment_data, request)
          response = @client.call(:refund, message: with_credentials({
            payment_data: payment_data,
            request: request
          }))

          response.body[:refund_response][:refund_result]
        end

        def remove_points(payment_data, request)
          response = @client.call(:remove_points, message: with_credentials({
            payment_data: payment_data,
            request: request
          }))

          response.body[:remove_points_response][:remove_points_result]
        end
        
        def sale(payment_data, request)
          response = @client.call(:sale, message: with_credentials({
            payment_data: payment_data,
            request: request
          }))

          response.body[:sale_response][:sale_result]
        end

        def void(request)
          response = @client.call(:void, message: with_credentials({
            request: request
          }))

          response.body[:void_response][:void_result]
        end
      end
    end
  end
end
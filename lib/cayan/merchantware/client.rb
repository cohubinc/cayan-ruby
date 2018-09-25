require 'savon'

module Cayan
  module Merchantware
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

        response[:board_card_response][:board_card_result]
      end

      def find_boarded_card(token:)
        response = @client.call(:find_boarded_card, message: with_credentials({
          request: {
            vault_token: token
          }
        }))

        response[:find_boarded_card_response][:find_boarded_card_result]
      end

      
    end
  end
end
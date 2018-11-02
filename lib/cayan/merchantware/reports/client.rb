require 'savon'

module Cayan
  module Merchantware
    module Reports
      class Client
        @client = nil
        attr_accessor :credentials

        def initialize(credentials)
          @credentials = credentials
          @client = Savon.client(
            wsdl: 'https://ps1.merchantware.net/Merchantware/ws/TransactionHistory/v4/Reporting.asmx?WSDL',
            convert_request_keys_to: :camelcase
          )
        end

        def current_batch_summary(filters)
          response = @client.call(:current_batch_summary, message: credentials.merge(filters))

          response.body[:current_batch_summary_response][:current_batch_summary_result]
        end

        def current_batch_transactions
          response = @client.call(:current_batch_transactions, message: credentials)
          
          response.body[:current_batch_transactions_response][:current_batch_transactions_result]
        end

        def summary_by_date(filters)
          response = @client.call(:summary_by_date, message: credentials.merge(filters))

          response.body[:summary_by_date_response][:summary_by_date_result]
        end
        
        def transactions_by_date(filters)
          response = @client.call(:transactions_by_date, message: credentials.merge(filters))

          response.body[:transactions_by_date_response][:transactions_by_date_result]
        end

        def transactions_by_reference(filters)
          response = @client.call(:transactions_by_date, message: credentials.merge(filters))

          response.body[:transactions_by_reference_response][:transactions_by_reference_result]
        end

        def transactions_by_transaction_id(transaction_id)
          response = @client.call(:detailed_transaction_by_transaction_id, message: credentials.merge({
            merchant_transaction_id: transaction_id
          }))
          
          response.body[:transactions_by_transaction_id_response][:transactions_by_transaction_id_result]
        end

        def detailed_transaction_by_reference(filters)
          response = @client.call(:detailed_transaction_by_reference, message: credentials.merge(filters))

          response.body[:detailed_transaction_by_reference_response][:detailed_transaction_by_reference_result]
        end

        def detailed_transaction_by_transaction_id(transaction_id)
          response = @client.call(:detailed_transaction_by_transaction_id, message: credentials.merge({
            merchant_transaction_id: transaction_id
          }))

          response.body[:detailed_transaction_by_transaction_id_response][:detailed_transaction_by_transaction_id_result]
        end
      end
    end
  end
end
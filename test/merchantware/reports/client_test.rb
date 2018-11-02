require "test_helper"

module Merchantware
  module Reports
    class ClientTest < Minitest::Test
      include WebMock::API

      SERVICE_ENDPOINT = "https://ps1.merchantware.net/Merchantware/ws/TransactionHistory/v4/Reporting.asmx"
      WSDL_URL = "#{SERVICE_ENDPOINT}?WSDL"
      
      def setup
        stub_request(:get, WSDL_URL).
          to_return(status: 200, body: File.read("test/fixtures/merchantware/reports.wsdl"))

        @client = Cayan::Merchantware::Reports::Client.new({
          merchant_name: 'Zero Inc',
          merchant_site_id: '00000000',
          merchant_key: '00000-00000-00000-00000-00000'
        })
      end

      def test_initialize
        assert_equal 'Zero Inc', @client.credentials[:merchant_name]
        assert '00000000', @client.credentials[:merchant_site_id]
        assert '00000-00000-00000-00000-00000', @client.credentials[:merchant_key]
      end

      def test_current_batch_summary
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/TransactionHistory/v4/Reporting.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/40/Reports/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:CurrentBatchSummary><tns:merchantName>Zero Inc</tns:merchantName><tns:merchantSiteId>00000000</tns:merchantSiteId><tns:merchantKey>00000-00000-00000-00000-00000</tns:merchantKey><tns:cardHolderFilter>JANE DOE</tns:cardHolderFilter><tns:cardType>0</tns:cardType></tns:CurrentBatchSummary></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/reports/current_batch_summary.xml"))

        result = @client.current_batch_summary({
          card_holder_filter: 'JANE DOE',
          card_type: '0'
        })
        
        assert_equal 2, result[:transaction_summary4].count
        assert_equal "JANE DOE/CHASE AIRMILES PLUS", result[:transaction_summary4][0][:cardholder]
        assert_equal "JANE DOE/AMERICAN EXPRESS", result[:transaction_summary4][1][:cardholder]
      end

      def test_current_batch_transactions
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/TransactionHistory/v4/Reporting.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/40/Reports/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:CurrentBatchTransactions><tns:merchantName>Zero Inc</tns:merchantName><tns:merchantSiteId>00000000</tns:merchantSiteId><tns:merchantKey>00000-00000-00000-00000-00000</tns:merchantKey></tns:CurrentBatchTransactions></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/reports/current_batch_transactions.xml"))
        
        result = @client.current_batch_transactions
        assert_equal "2980983", result[:transaction_reference4][0][:token]
        assert_equal "2980989", result[:transaction_reference4][1][:token]
      end

      def test_summary_by_date
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/TransactionHistory/v4/Reporting.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/40/Reports/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:SummaryByDate><tns:merchantName>Zero Inc</tns:merchantName><tns:merchantSiteId>00000000</tns:merchantSiteId><tns:merchantKey>00000-00000-00000-00000-00000</tns:merchantKey><tns:startDate>2017-12-01T05:00:00</tns:startDate><tns:endDate>2017-12-31T05:00:00</tns:endDate><tns:cardholderFilter>REWARDS</tns:cardholderFilter><tns:cardType>0</tns:cardType></tns:SummaryByDate></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/reports/summary_by_date.xml"))
        
        result = @client.summary_by_date({
          start_date: '2017-12-01T05:00:00',
          end_date: '2017-12-31T05:00:00',
          cardholder_filter: 'REWARDS',
          card_type: '0'
        })
        
        assert_equal 2, result[:transaction_summary4].count
        assert_equal "CITI REWARDS CARD", result[:transaction_summary4][0][:cardholder]
        assert_equal "RBS REWARDS CARD", result[:transaction_summary4][1][:cardholder]
      end

      def test_transactions_by_date
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/TransactionHistory/v4/Reporting.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/40/Reports/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:TransactionsByDate><tns:merchantName>Zero Inc</tns:merchantName><tns:merchantSiteId>00000000</tns:merchantSiteId><tns:merchantKey>00000-00000-00000-00000-00000</tns:merchantKey><tns:startDate>2008-05-01T01:00:00</tns:startDate><tns:endDate>2008-06-01T13:00:00</tns:endDate><tns:invoiceNumber>1000</tns:invoiceNumber><tns:registerNumber></tns:registerNumber><tns:authorizationCode></tns:authorizationCode></tns:TransactionsByDate></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/reports/transactions_by_date.xml"))
        
        result = @client.transactions_by_date({
          start_date: '2008-05-01T01:00:00',
          end_date: '2008-06-01T13:00:00',
          invoice_number: '1000',
          register_number: '',
          authorization_code: ''
        })
        
        assert_equal 2, result[:transaction_reference4].count
        assert_equal "302856", result[:transaction_reference4][0][:token]
        assert_equal "10002", result[:transaction_reference4][0][:invoice_number]
        assert_equal "VISA TEST CARD", result[:transaction_reference4][0][:cardholder]
      end

      def test_transactions_by_reference
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/TransactionHistory/v4/Reporting.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/40/Reports/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:TransactionsByDate><tns:merchantName>Zero Inc</tns:merchantName><tns:merchantSiteId>00000000</tns:merchantSiteId><tns:merchantKey>00000-00000-00000-00000-00000</tns:merchantKey><tns:token>375814</tns:token></tns:TransactionsByDate></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/reports/transactions_by_reference.xml"))
        
        result = @client.transactions_by_reference({
          token: '375814'
        })
        
        assert_equal "9980", result[:transaction_reference4][:invoice_number]
        assert_equal "John Doe", result[:transaction_reference4][:cardholder]
      end

      def test_transactions_by_transaction_id
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/TransactionHistory/v4/Reporting.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/40/Reports/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:DetailedTransactionByTransactionId><tns:merchantName>Zero Inc</tns:merchantName><tns:merchantSiteId>00000000</tns:merchantSiteId><tns:merchantKey>00000-00000-00000-00000-00000</tns:merchantKey><tns:merchantTransactionId>448254125</tns:merchantTransactionId></tns:DetailedTransactionByTransactionId></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/reports/transactions_by_transaction_id.xml"))
        
        result = @client.transactions_by_transaction_id("448254125")
        
        assert_equal "DECLINED", result[:transaction_reference4][:approval_status]
        assert_equal "************1117", result[:transaction_reference4][:card_number]
      end

      def test_detailed_transaction_by_reference
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/TransactionHistory/v4/Reporting.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/40/Reports/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:DetailedTransactionByReference><tns:merchantName>Zero Inc</tns:merchantName><tns:merchantSiteId>00000000</tns:merchantSiteId><tns:merchantKey>00000-00000-00000-00000-00000</tns:merchantKey><tns:token>375814</tns:token></tns:DetailedTransactionByReference></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/reports/detailed_transaction_by_reference.xml"))

        result = @client.detailed_transaction_by_reference({
          token: "375814"
        })

        assert_equal "DECLINED", result[:approval_status]
        assert_equal "John Doe", result[:cardholder]
      end

      def test_detailed_transaction_by_transaction_id
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/TransactionHistory/v4/Reporting.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/40/Reports/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:DetailedTransactionByTransactionId><tns:merchantName>Zero Inc</tns:merchantName><tns:merchantSiteId>00000000</tns:merchantSiteId><tns:merchantKey>00000-00000-00000-00000-00000</tns:merchantKey><tns:merchantTransactionId>DEV101</tns:merchantTransactionId></tns:DetailedTransactionByTransactionId></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/reports/detailed_transaction_by_transaction_id.xml"))
        
        result = @client.detailed_transaction_by_transaction_id("DEV101")
        assert_equal 'DECLINED', result[:approval_status]
        assert_equal '5.00', result[:authorization_amount]
        assert_equal 'PIN VERIFIED', result[:emv][:pin_statement]
      end
    end
  end
end
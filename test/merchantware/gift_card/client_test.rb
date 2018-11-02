require "test_helper"

module Merchantware
  module GiftCard
    class ClientTest < Minitest::Test
      include WebMock::API

      SERVICE_ENDPOINT = "https://ps1.merchantware.net/Merchantware/ws/ExtensionServices/v45/Giftcard.asmx"
      WSDL_URL = "#{SERVICE_ENDPOINT}?WSDL"
      
      def setup
        stub_request(:get, WSDL_URL).
          to_return(status: 200, body: File.read("test/fixtures/merchantware/gift_card.wsdl"))

        @client = Cayan::Merchantware::GiftCard::Client.new({
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

      def test_activate_card
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/ExtensionServices/v45/Giftcard.asmx")
            .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/45/Giftcard\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:ActivateCard><tns:PaymentData><tns:Source>READER</tns:Source><tns:TrackData>%1234567890123456^GIFTCARD/TEST^00000000000000000?;1234567890123456=00000000000000000?</tns:TrackData></tns:PaymentData><tns:Request><tns:Amount>1.29</tns:Amount><tns:InvoiceNumber>Transaction1000</tns:InvoiceNumber><tns:MerchantTransactionId>a1234</tns:MerchantTransactionId></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:ActivateCard></env:Body></env:Envelope>",)
            .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/gift_card/activate_card.xml"))
        
        result = @client.activate_card(
          {
            source: 'READER',
            track_data: '%1234567890123456^GIFTCARD/TEST^00000000000000000?;1234567890123456=00000000000000000?'
          },
          {
            amount: '1.29',
            invoice_number: 'Transaction1000',
            merchant_transaction_id: 'a1234'
          }
        )

        assert_equal "APPROVED", result[:approval_status]
        assert_equal "1.29", result[:gift][:approved_amount]
        assert_equal "1.29", result[:gift][:requested_amount]
        assert_equal "1.29", result[:gift][:redeemable_balance]
      end

      def test_add_points
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/ExtensionServices/v45/Giftcard.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/45/Giftcard\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:AddPoints><tns:PaymentData><tns:Source>READER</tns:Source><tns:TrackData>%1234567890123456^GIFTCARD/TEST^00000000000000000?;1234567890123456=00000000000000000?</tns:TrackData></tns:PaymentData><tns:Request><tns:AmountType>Points</tns:AmountType><tns:Amount>129</tns:Amount><tns:InvoiceNumber>Transaction1000</tns:InvoiceNumber><tns:MerchantTransactionId>a1234</tns:MerchantTransactionId></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:AddPoints></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/gift_card/add_points.xml"))

        result = @client.add_points(
          {
            source: 'READER',
            track_data: '%1234567890123456^GIFTCARD/TEST^00000000000000000?;1234567890123456=00000000000000000?'
          },
          {
            amount_type: 'Points',
            amount: '129',
            invoice_number: 'Transaction1000',
            merchant_transaction_id: 'a1234'
          }
        )

        assert_equal "APPROVED", result[:approval_status]
        assert_equal "POINTS", result[:loyalty][:points_type]
        assert_equal "129", result[:loyalty][:approved_points]
      end

      def test_add_value
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/ExtensionServices/v45/Giftcard.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/45/Giftcard\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:AddValue><tns:PaymentData><tns:Source>READER</tns:Source><tns:TrackData>%1234567890123456^GIFTCARD/TEST^00000000000000000?;1234567890123456=00000000000000000?</tns:TrackData></tns:PaymentData><tns:Request><tns:Amount>1.29</tns:Amount><tns:InvoiceNumber>Transaction1000</tns:InvoiceNumber><tns:MerchantTransactionId>a1234</tns:MerchantTransactionId></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:AddValue></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/gift_card/add_value.xml"))
        
        result = @client.add_value(
          {
            source: 'READER',
            track_data: '%1234567890123456^GIFTCARD/TEST^00000000000000000?;1234567890123456=00000000000000000?'
          },
          {
            amount: '1.29',
            invoice_number: 'Transaction1000',
            merchant_transaction_id: 'a1234'
          }
        )

        assert_equal "APPROVED", result[:approval_status]
        assert_equal "1.29", result[:gift][:approved_amount]
        assert_equal "1.29", result[:gift][:requested_amount]
        assert_equal "100.00", result[:gift][:redeemable_balance]
      end

      def test_balance_inquiry
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/ExtensionServices/v45/Giftcard.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/45/Giftcard\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:BalanceInquiry><tns:PaymentData><tns:Source>READER</tns:Source><tns:TrackData>%1234567890123456^GIFTCARD/TEST^00000000000000000?;1234567890123456=00000000000000000?</tns:TrackData></tns:PaymentData><tns:Request><tns:InvoiceNumber>Transaction1000</tns:InvoiceNumber></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:BalanceInquiry></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/gift_card/balance_inquiry.xml"))
        
        result = @client.balance_inquiry(
          {
            source: 'READER',
            track_data: '%1234567890123456^GIFTCARD/TEST^00000000000000000?;1234567890123456=00000000000000000?'
          },
          {
            invoice_number: 'Transaction1000'
          }
        )

        assert_equal "APPROVED", result[:approval_status]
        assert_equal "MC0110", result[:token]
        assert_equal "Transaction1000", result[:invoice_number]
        assert_equal "080729", result[:expiration_date]
        assert_equal "90.00", result[:gift][:gift_balance]
        assert_equal "10.00", result[:gift][:rewards_balance]
        assert_equal "100.00", result[:gift][:redeemable_balance]
        assert_equal "100.00", result[:gift][:redeemable_balance]
        assert_equal "62346", result[:loyalty][:points_balance]
      end

      def test_refund
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/ExtensionServices/v45/Giftcard.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/45/Giftcard\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:Refund><tns:PaymentData><tns:Source>PREVIOUSTRANSACTION</tns:Source><tns:Token>12345678</tns:Token></tns:PaymentData><tns:Request><tns:Amount>1.29</tns:Amount><tns:InvoiceNumber>Transaction1000</tns:InvoiceNumber><tns:MerchantTransactionId>a1234</tns:MerchantTransactionId></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:Refund></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/gift_card/refund.xml"))
        
        result = @client.refund(
          {
            source: 'PREVIOUSTRANSACTION',
            token: '12345678'
          },
          {
            amount: '1.29',
            invoice_number: 'Transaction1000',
            merchant_transaction_id: 'a1234'
          }
        )

        assert_equal "APPROVED", result[:approval_status]
        assert_equal "928061", result[:response_message]
        assert_equal "1.29", result[:gift][:approved_amount]
        assert_equal "1.29", result[:gift][:requested_amount]
        assert_equal "100.00", result[:gift][:redeemable_balance]
      end

      def test_remove_points
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/ExtensionServices/v45/Giftcard.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/45/Giftcard\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:RemovePoints><tns:PaymentData><tns:Source>PREVIOUSTRANSACTION</tns:Source><tns:Token>12345678</tns:Token></tns:PaymentData><tns:Request><tns:AmountType>Currency</tns:AmountType><tns:Amount>1.29</tns:Amount><tns:InvoiceNumber>Transaction1000</tns:InvoiceNumber><tns:MerchantTransactionId>a1234</tns:MerchantTransactionId></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:RemovePoints></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/gift_card/remove_points.xml"))
        
        result = @client.remove_points(
          {
            source: 'PREVIOUSTRANSACTION',
            token: '12345678'
          },
          {
            amount_type: 'Currency',
            amount: '1.29',
            invoice_number: 'Transaction1000',
            merchant_transaction_id: 'a1234'
          }
        )

        assert_equal "APPROVED", result[:approval_status]
        assert_equal "Frequency", result[:loyalty][:points_type]
        assert_equal "1", result[:loyalty][:approved_points]
        assert_equal "5", result[:loyalty][:points_before_next_reward]
        assert_equal "62346", result[:loyalty][:points_balance]
      end

      def test_sale
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/ExtensionServices/v45/Giftcard.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/45/Giftcard\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:Sale><tns:PaymentData><tns:Source>READER</tns:Source><tns:TrackData>%1234567890123456^GIFTCARD/TEST^00000000000000000?;1234567890123456=00000000000000000?</tns:TrackData></tns:PaymentData><tns:Request><tns:Amount>1.29</tns:Amount><tns:InvoiceNumber>Transaction1000</tns:InvoiceNumber><tns:EnablePartialAuthorization>True</tns:EnablePartialAuthorization><tns:MerchantTransactionId>a1234</tns:MerchantTransactionId></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:Sale></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/gift_card/sale.xml"))
        
        result = @client.sale(
          {
            source: 'READER',
            track_data: '%1234567890123456^GIFTCARD/TEST^00000000000000000?;1234567890123456=00000000000000000?'
          },
          {
            amount: '1.29',
            invoice_number: 'Transaction1000',
            enable_partial_authorization: 'True',
            merchant_transaction_id: 'a1234'
          }
        )

        assert_equal "APPROVED", result[:approval_status]
        assert_equal "928061", result[:response_message]
        assert_equal "1.00", result[:gift][:approved_amount]
        assert_equal "1.29", result[:gift][:requested_amount]
        assert_equal "100.00", result[:gift][:redeemable_balance]
      end

      def test_void
        stub_request(:post, "https://ps1.merchantware.net/Merchantware/ws/ExtensionServices/v45/Giftcard.asmx")
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/45/Giftcard\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:Void><tns:Request><tns:Token>1234567890</tns:Token><tns:InvoiceNumber>Transaction1000</tns:InvoiceNumber></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:Void></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/gift_card/void.xml"))
        
        result = @client.void({
          token: '1234567890',
          invoice_number: 'Transaction1000'
        })

        assert_equal "APPROVED", result[:approval_status]
        assert_equal "1.29", result[:gift][:approved_amount]
        assert_equal "100.00", result[:gift][:redeemable_balance]
      end
    end
  end
end
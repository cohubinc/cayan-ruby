require "test_helper"

module Merchantware
  module Credit
    class ClientTest < Minitest::Test
      include WebMock::API

      SERVICE_ENDPOINT = "https://ps1.merchantware.net/Merchantware/ws/RetailTransaction/v45/Credit.asmx"
      WSDL_URL = "#{SERVICE_ENDPOINT}?WSDL"
      
      def setup
        stub_request(:get, WSDL_URL).
          to_return(status: 200, body: File.read("test/fixtures/merchantware/credit.wsdl"))

        @client = Cayan::Merchantware::Credit::Client.new({
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

      def test_board_card
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:BoardCard><tns:PaymentData><tns:Source>Keyed</tns:Source><tns:CardNumber>4012000033330026</tns:CardNumber><tns:ExpirationDate>1218</tns:ExpirationDate><tns:CardHolder>John Doe</tns:CardHolder><tns:AvsStreetAddress>1 Federal Street</tns:AvsStreetAddress><tns:AvsZipCode>02110</tns:AvsZipCode></tns:PaymentData><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:BoardCard></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/board_card.xml"))
        
        result = @client.board_card({
          source: 'Keyed',
          card_number: '4012000033330026',
          expiration_date: '1218',
          card_holder: 'John Doe',
          avs_street_address: '1 Federal Street',
          avs_zip_code: '02110'
        })

        assert_equal '1000000000002WSZECPL', result[:vault_token]
        assert_nil result[:error_code]
        assert_nil result[:error_message]
      end

      def test_find_boarded_card
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:FindBoardedCard><tns:Request><tns:VaultToken>127MMEIIQVEW2WSZECPL</tns:VaultToken></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:FindBoardedCard></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/find_boarded_card.xml"))
        
        result = @client.find_boarded_card({ vault_token: '127MMEIIQVEW2WSZECPL' })
        
        assert_equal '0026', result[:card_number]
        assert_equal '1218', result[:expiration_date]
        assert_equal '4', result[:card_type]
        assert_equal '1 Federal Street', result[:avs_street_address]
        assert_equal '02110', result[:avs_zip_code]
      end

      def test_adjust_tip
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:AdjustTip><tns:Request><tns:Token>1236559</tns:Token><tns:Amount>1.00</tns:Amount></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:AdjustTip></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/adjust_tip.xml"))
        
        result = @client.adjust_tip({ token: '1236559', amount: '1.00' })

        assert_equal 'APPROVED', result[:approval_status]
        assert_equal '1236560', result[:token]
        assert_equal '3/14/2016 7:54:23 PM', result[:transaction_date]
      end
      
      def test_attach_signature
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:AttachSignature><tns:Request><tns:Token>608957</tns:Token><tns:VectorImageData>10,10^110,110^0,65535^10,110^110,10^0,65535^~</tns:VectorImageData></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:AttachSignature></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/attach_signature.xml"))
        
        result = @client.attach_signature({ token: '608957', vector_image_data: '10,10^110,110^0,65535^10,110^110,10^0,65535^~' })

        assert_equal 'ACCEPTED', result[:upload_status]
        assert_equal '608957', result[:token]
        assert_equal '3/14/2016 7:57:32 PM', result[:transaction_date]
      end
      
      def test_authorize
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:Authorize><tns:PaymentData><tns:Source>Keyed</tns:Source><tns:CardNumber>4012000033330026</tns:CardNumber><tns:ExpirationDate>1218</tns:ExpirationDate><tns:CardHolder>John Doe</tns:CardHolder><tns:AvsStreetAddress>1 Federal Street</tns:AvsStreetAddress><tns:AvsZipCode>02110</tns:AvsZipCode><tns:CardVerificationValue>123</tns:CardVerificationValue></tns:PaymentData><tns:Request><tns:Amount>1.05</tns:Amount><tns:InvoiceNumber>1556</tns:InvoiceNumber><tns:RegisterNumber>35</tns:RegisterNumber><tns:MerchantTransactionId>167901</tns:MerchantTransactionId><tns:CardAcceptorTerminalId>3</tns:CardAcceptorTerminalId></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:Authorize></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/authorize.xml"))
        
        result = @client.authorize({
            source: 'Keyed',
            card_number: '4012000033330026',
            expiration_date: '1218',
            card_holder: 'John Doe',
            avs_street_address: '1 Federal Street',
            avs_zip_code: '02110',
            card_verification_value: '123'
          }, {
            amount: 1.05,
            invoice_number: '1556',
            register_number: '35',
            merchant_transaction_id: '167901',
            card_acceptor_terminal_id: '3'
          }
        )

        assert_equal 'APPROVED', result[:approval_status]
        assert_equal '608958', result[:token]
        assert_equal 'OK785C', result[:authorization_code]
        assert_equal '3/14/2016 7:58:33 PM', result[:transaction_date]
        assert_equal '1.05', result[:amount]
        assert_equal '************0026', result[:card_number]
        assert_equal 'John Doe', result[:cardholder]
        assert_equal '4', result[:card_type]
        assert_equal '1', result[:reader_entry_mode]
        assert_equal 'Y', result[:avs_response]
      end

      def test_capture
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:Capture><tns:Request><tns:Token>608939</tns:Token><tns:Amount>1.5</tns:Amount><tns:InvoiceNumber>1556</tns:InvoiceNumber><tns:RegisterNumber>35</tns:RegisterNumber><tns:MerchantTransactionId>167902</tns:MerchantTransactionId><tns:CardAcceptorTerminalId>3</tns:CardAcceptorTerminalId></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:Capture></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/capture.xml"))
        
        result = @client.capture({
          token: '608939',
          amount: 1.50,
          invoice_number: '1556',
          register_number: '35',
          merchant_transaction_id: '167902',
          card_acceptor_terminal_id: '3'
        })

        assert_equal 'APPROVED', result[:approval_status]
        assert_equal '608961', result[:token]
        assert_equal 'OK036C', result[:authorization_code]
        assert_equal '3/14/2016 8:09:31 PM', result[:transaction_date]
        assert_equal '1.50', result[:amount]
      end
      
      def test_update_boarded_card
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:UpdateBoardedCard><tns:Request><tns:Token>127MMEIIQVEW2WSZECPL</tns:Token><tns:ExpirationDate>0118</tns:ExpirationDate></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:UpdateBoardedCard></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/update_boarded_card.xml"))
        
        result = @client.update_boarded_card({
          token: '127MMEIIQVEW2WSZECPL',
          expiration_date: '0118'
        })

        assert_equal '127MMEIIQVEW2WSZECPL', result[:vault_token]
      end
      
      def test_force_capture
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:ForceCapture><tns:PaymentData><tns:Source>Keyed</tns:Source><tns:CardNumber>4012000033330026</tns:CardNumber><tns:ExpirationDate>1218</tns:ExpirationDate><tns:CardHolder>John Doe</tns:CardHolder></tns:PaymentData><tns:Request><tns:Amount>3.06</tns:Amount><tns:AuthorizationCode>V00546C</tns:AuthorizationCode><tns:InvoiceNumber>1559</tns:InvoiceNumber><tns:RegisterNumber>35</tns:RegisterNumber><tns:MerchantTransactionId>168901</tns:MerchantTransactionId><tns:CardAcceptorTerminalId>3</tns:CardAcceptorTerminalId><tns:EcommerceTransactionIndicator xsi:nil=\"true\"/></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:ForceCapture></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/force_capture.xml"))
        
        result = @client.force_capture(
          {
            source: 'Keyed',
            card_number: '4012000033330026',
            expiration_date: '1218',
            card_holder: 'John Doe'
          }, {
            amount: '3.06',
            authorization_code: 'V00546C',
            invoice_number: '1559',
            register_number: '35',
            merchant_transaction_id: '168901',
            card_acceptor_terminal_id: '3',
            ecommerce_transaction_indicator: nil
          }
        )

        assert_equal 'APPROVED', result[:approval_status]
        assert_equal '608962', result[:token]
        assert_equal 'V00546C', result[:authorization_code]
        assert_equal '3/14/2016 8:11:01 PM', result[:transaction_date]
        assert_equal '3.06', result[:amount]
        assert_equal '************0026', result[:card_number]
        assert_equal 'John Doe', result[:cardholder]
        assert_equal '4', result[:card_type]
      end

      def test_refund
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:Refund><tns:PaymentData><tns:Source>Keyed</tns:Source><tns:CardNumber>4012000033330026</tns:CardNumber><tns:ExpirationDate>1218</tns:ExpirationDate><tns:CardHolder>John Doe</tns:CardHolder></tns:PaymentData><tns:Request><tns:Amount>4.01</tns:Amount><tns:InvoiceNumber>1701</tns:InvoiceNumber><tns:RegisterNumber>35</tns:RegisterNumber><tns:MerchantTransactionId>165901</tns:MerchantTransactionId><tns:CardAcceptorTerminalId>3</tns:CardAcceptorTerminalId><tns:EcommerceTransactionIndicator xsi:nil=\"true\"/></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:Refund></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/refund.xml"))

        result = @client.refund(
          {
            source: 'Keyed',
            card_number: '4012000033330026',
            expiration_date: '1218',
            card_holder: 'John Doe'
          }, {
            amount: '4.01',
            invoice_number: '1701',
            register_number: '35',
            merchant_transaction_id: '165901',
            card_acceptor_terminal_id: '3',
            ecommerce_transaction_indicator: nil
          }
        )

        assert_equal 'APPROVED', result[:approval_status]
        assert_equal '608963', result[:token]
        assert_equal '3/14/2016 8:12:50 PM', result[:transaction_date]
        assert_equal '4.01', result[:amount]
        assert_equal '************0026', result[:card_number]
        assert_equal 'John Doe', result[:cardholder]
        assert_equal '4', result[:card_type]
      end
      
      def test_sale
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:Sale><tns:PaymentData><tns:Source>Keyed</tns:Source><tns:CardNumber>4012000033330026</tns:CardNumber><tns:ExpirationDate>1218</tns:ExpirationDate><tns:CardHolder>John Doe</tns:CardHolder><tns:AvsStreetAddress>1 Federal Street</tns:AvsStreetAddress><tns:AvsZipCode>02110</tns:AvsZipCode><tns:CardVerificationValue>123</tns:CardVerificationValue></tns:PaymentData><tns:Request><tns:Amount>1.05</tns:Amount><tns:CashbackAmount>0.00</tns:CashbackAmount><tns:SurchargeAmount>0.00</tns:SurchargeAmount><tns:TaxAmount>0.00</tns:TaxAmount><tns:InvoiceNumber>1556</tns:InvoiceNumber><tns:PurchaseOrderNumber>17801</tns:PurchaseOrderNumber><tns:CustomerCode>20</tns:CustomerCode><tns:RegisterNumber>35</tns:RegisterNumber><tns:MerchantTransactionId>166901</tns:MerchantTransactionId><tns:CardAcceptorTerminalId>3</tns:CardAcceptorTerminalId><tns:EnablePartialAuthorization>False</tns:EnablePartialAuthorization><tns:ForceDuplicate>False</tns:ForceDuplicate><tns:EcommerceTransactionIndicator xsi:nil=\"true\"/></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:Sale></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/sale.xml"))

        result = @client.sale(
          {
            source: 'Keyed',
            card_number: '4012000033330026',
            expiration_date: '1218',
            card_holder: 'John Doe',
            avs_street_address: '1 Federal Street',
            avs_zip_code: '02110',
            card_verification_value: '123'
          }, {
            amount: '1.05',
            cashback_amount: '0.00',
            surcharge_amount: '0.00',
            tax_amount: '0.00',
            invoice_number: '1556',
            purchase_order_number: '17801',
            customer_code: '20',
            register_number: '35',
            merchant_transaction_id: '166901',
            card_acceptor_terminal_id: '3',
            enable_partial_authorization: 'False',
            force_duplicate: 'False',
            ecommerce_transaction_indicator: nil
          }
        )

        assert_equal 'APPROVED', result[:approval_status]
        assert_equal '608957', result[:token]
        assert_equal 'OK775C', result[:authorization_code]
        assert_equal '3/14/2016 7:57:22 PM', result[:transaction_date]
        assert_equal '1.05', result[:amount]
        assert_equal '************0026', result[:card_number]
        assert_equal 'John Doe', result[:cardholder]
        assert_equal '4', result[:card_type]
        assert_equal 'Y', result[:avs_response]
      end

      def test_settle_batch
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:SettleBatch><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:SettleBatch></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/settle_batch.xml"))

        result = @client.settle_batch

        assert_equal 'SUCCESS', result[:batch_status]
        assert_equal '0314160001', result[:authorization_code]
        assert_equal '2.19', result[:batch_amount]
        assert_equal '8', result[:transaction_count]
        assert_equal '3/14/2016 8:28:30 PM', result[:transaction_date]
      end

      def test_unboard_card
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:UnboardCard><tns:Request><tns:VaultToken>MYTOKENVALUEX</tns:VaultToken></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:UnboardCard></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/unboard_card.xml"))
        
        result = @client.unboard_card({ vault_token: "MYTOKENVALUEX" })

        assert_equal 'MYTOKENVALUEX', result[:vault_token]
        assert_nil result[:error_code]
        assert_nil result[:error_message]
      end
      
      def test_void
        stub_request(:post, SERVICE_ENDPOINT)
          .with(body: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><env:Envelope xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:tns=\"http://schemas.merchantwarehouse.com/merchantware/v45/\" xmlns:env=\"http://schemas.xmlsoap.org/soap/envelope/\"><env:Body><tns:Void><tns:Request><tns:Token>608973</tns:Token><tns:RegisterNumber>35</tns:RegisterNumber><tns:MerchantTransactionId>167901</tns:MerchantTransactionId><tns:CardAcceptorTerminalId>3</tns:CardAcceptorTerminalId></tns:Request><tns:Credentials><tns:MerchantName>Zero Inc</tns:MerchantName><tns:MerchantSiteId>00000000</tns:MerchantSiteId><tns:MerchantKey>00000-00000-00000-00000-00000</tns:MerchantKey></tns:Credentials></tns:Void></env:Body></env:Envelope>")
          .to_return(status: 200, body: File.read("test/fixtures/merchantware/responses/credit/void.xml"))
        
        result = @client.void({ token: "608973", register_number: '35', merchant_transaction_id: '167901', card_acceptor_terminal_id: '3' })

        assert_equal 'APPROVED', result[:approval_status]
        assert_equal '608974', result[:token]
        assert_equal 'VOID', result[:authorization_code]
        assert_equal '3/14/2016 8:30:18 PM', result[:transaction_date]
        assert_nil result[:error_code]
        assert_nil result[:error_message]
      end
    end
  end
end
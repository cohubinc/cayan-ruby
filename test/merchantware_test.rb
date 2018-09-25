require "test_helper"

class MerchantwareTest < Minitest::Test
  def setup
    @client = Cayan::Merchantware::Client.new(
      merchant_name: 'NAME',
      merchant_site_id: 'SITEID',
      merchant_key: '00000-00000-00000-00000-00000'
    )
  end

  def test_initialize
    assert_equal 'NAME', @client.merchant_name
    assert 'SITEID', @client.merchant_site_id
    assert '00000-00000-00000-00000-00000', @client.merchant_key
  end

  def test_board_card
    response = @client.board_card(payment_data: {
      'Source' => 'Keyed',
      'CardNumber' => '4012000033330026',
      'ExpirationDate' => '1218'
    })

    binding.pry
  end

  def test_find_boarded_card
    response = @client.find_boarded_card(token: '100000100MIBUADAJCCC')

    binding.pry
  end
end

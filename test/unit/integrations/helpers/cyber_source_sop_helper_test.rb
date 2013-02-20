require 'test_helper'

class CyberSourceSopHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @helper = CyberSourceSop::Helper.new('order-500', 'CyberSource_TestID',
      :amount => 500, :currency => 'AED')
  end

  def test_basic_helper_fields
    assert_field 'merchantID', 'CyberSource_TestID'
    assert_field 'currency', 'AED'
    assert_field 'amount', '500'
    assert_field 'orderNumber', 'order-500'
  end

  def test_customer_fields
    @helper.customer :first_name => 'Cody', :last_name => 'Fauser',
      :email => 'cody@example.com', phone: '(555)555-5555'
    assert_field 'billTo_firstName', 'Cody'
    assert_field 'billTo_lastName', 'Fauser'
    assert_field 'billTo_email', 'cody@example.com'
    assert_field 'billTo_phoneNumber', '(555)555-5555'
  end

  def test_billing_address_mapping
    @helper.billing_address :address1 => '1 My Street',
      :address2 => '',
      :city => 'Leeds',
      :state => 'Yorkshire',
      :country  => 'CA'

    assert_field 'billTo_street1', '1 My Street'
    assert_field 'billTo_city', 'Leeds'
    assert_field 'billTo_state', 'Yorkshire'
    assert_field 'billTo_country', 'CA'
  end

  def test_shipping_address_mapping
    @helper.shipping_address :address1 => '1 My Street',
      :address2 => '',
      :city => 'Leeds',
      :state => 'Yorkshire',
      :country  => 'CA'

    assert_field 'shipTo_street1', '1 My Street'
    assert_field 'shipTo_city', 'Leeds'
    assert_field 'shipTo_state', 'Yorkshire'
    assert_field 'shipTo_country', 'CA'
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end

  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end

end

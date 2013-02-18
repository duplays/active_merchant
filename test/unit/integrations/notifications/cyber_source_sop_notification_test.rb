require 'test_helper'

class CyberSourceSopNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @cyber_source_sop = CyberSourceSop::Notification.new(http_raw_data)
  end

  def test_accessors
    assert @cyber_source_sop.complete?
    assert_equal "", @cyber_source_sop.status
    assert_equal "", @cyber_source_sop.transaction_id
    assert_equal "", @cyber_source_sop.item_id
    assert_equal "", @cyber_source_sop.gross
    assert_equal "", @cyber_source_sop.currency
    assert_equal "", @cyber_source_sop.received_at
    assert @cyber_source_sop.test?
  end

  def test_compositions
    assert_equal Money.new(3166, 'USD'), @cyber_source_sop.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement

  end

  def test_send_acknowledgement
  end

  def test_respond_to_acknowledge
    assert @cyber_source_sop.respond_to?(:acknowledge)
  end

  private
  def http_raw_data
    ""
  end
end

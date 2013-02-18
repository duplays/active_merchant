require 'test_helper'

class CyberSourceSopModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def test_notification_method
    assert_instance_of CyberSourceSop::Notification, CyberSourceSop.notification('name=cody')
  end
end

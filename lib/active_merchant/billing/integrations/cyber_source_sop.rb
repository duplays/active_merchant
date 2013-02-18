require File.dirname(__FILE__) + '/cyber_source_sop/helper.rb'
require File.dirname(__FILE__) + '/cyber_source_sop/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module CyberSourceSop

        mattr_accessor :service_url
        self.service_url = 'https://www.example.com'

        def self.notification(post)
          Notification.new(post)
        end
      end
    end
  end
end

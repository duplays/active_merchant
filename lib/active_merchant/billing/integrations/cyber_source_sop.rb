require File.dirname(__FILE__) + '/cyber_source_sop/helper.rb'
require File.dirname(__FILE__) + '/cyber_source_sop/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module CyberSourceSop

        mattr_accessor :production_url, :test_url

        self.production_url = 'https://orderpage.ic3.com/hop/ProcessOrder.do'
        self.test_url = 'https://orderpagetest.ic3.com/hop/ProcessOrder.do'

        def self.service_url
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
          when :production
            self.production_url
          when :test
            self.test_url
          else
            raise StandardError, "Integration mode set to an invalid value: #{mode}"
          end
        end

        def self.notification(post)
          Notification.new(post)
        end
      end
    end
  end
end

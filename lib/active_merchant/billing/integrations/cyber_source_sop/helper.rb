module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module CyberSourceSop
        class Helper < ActiveMerchant::Billing::Integrations::Helper

          mapping :order, 'orderNumber'

          mapping :customer,
            :first_name => 'billTo_firstName',
            :last_name  => 'billTo_lastName',
            :email      => 'billTo_email',
            :phone      => 'billTo_phoneNumber'

          mapping :billing_address,
            :city     => 'billTo_city',
            :address1 => 'billTo_street1',
            :address2 => 'billTo_street2',
            :state    => 'billTo_state',
            :country  => 'billTo_country'

          mapping :shipping_address,
            :city     => 'shipTo_city',
            :address1 => 'shipTo_street1',
            :address2 => 'shipTo_street2',
            :state    => 'shipTo_state',
            :country  => 'shipTo_country'

          mapping :description, 'comments'
          mapping :tax, 'taxAmount'

          mapping :notify_url, 'orderPage_merchantURLPostAddress'
          mapping :return_url, 'orderPage_receiptResponseURL'
          mapping :cancel_return_url, 'orderPage_cancelResponseURL'

        end
      end
    end
  end
end

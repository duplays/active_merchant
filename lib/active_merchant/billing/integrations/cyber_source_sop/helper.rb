module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module CyberSourceSop
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          mapping :order,    'orderNumber'
          mapping :account,  'merchantID'
          mapping :currency, 'currency'
          mapping :amount,   'amount'

          mapping :credential2 => 'orderPage_serialNumber'

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

          mapping :credit_card,
            :number               => 'card_accountNumber',
            :expiry_month         => 'card_expirationMonth',
            :expiry_year          => 'card_expirationYear',
            :verification_value   => 'card_cvNumber',
            :card_type            => 'card_cardType'

          mapping :notify_url, 'orderPage_merchantURLPostAddress'
          mapping :return_url, 'orderPage_receiptResponseURL'
          mapping :cancel_return_url, 'orderPage_cancelResponseURL'

          # These are the options that need to be used with payment_service_for with the
          # :cyber_source_sop service
          #
          # * :merchant_id => 'Your CyberSource SOP Merchant Id'
          # * :shared_secret => 'Your CyberSource SOP Shared Secret'
          # * :credential2 => 'Your CyberSource SOP Serial Number'
          #
          # The following are optional data that you can specify but will be set to sensible
          # defaults if they're not specified
          #
          # * :transaction_type   default: 'sale', can be: 'sale', 'authorize'
          #                       Determines the type of transaction this will be.  There's no concept of
          #                       capture *after* an authorization so 'sale' will most likely work for you
          # * :ignore_avs         default: 'true', can be: 'true', 'false'
          #                       Whether or not to ignore the AVS code when processing this transaction
          def initialize(order, account, options = {})
            requires!(options, :credential2)
            super

            add_field('orderPage_transactionType', options[:transaction_type].present ? options[:transaction_type] : 'sale')
            add_field('orderPage_ignoreAVS', options[:ignore_avs].present ? options[:ignore_avs] : 'true')
            add_field('orderPage_version', options[:version].present ? options[:version] : '7')
          end

          def valid_line_item?(item = {})
            item[:name].present? && item[:sku].present? && item[:unit_price].present?
          end

          def add_line_items(options = {})
            requires!(options, :line_items)

            valid_line_items = options[:line_items].select { |item| valid_line_item? item }
            add_field('lineItemCount', valid_line_items.size)

            valid_line_items.each_with_index do |item, idx|
              tax_amount = (item[:tax_amount].present && item[:tax_amount] >= 0.0) ? item[:tax_amount] : '0.00'
              quantity = item[:quantity].present ? item[:quantity] : 1

              add_field("item_#{idx}_productName", item[:name])
              add_field("item_#{idx}_productSKU", item[:sku])
              add_field("item_#{idx}_taxAmount", tax_amount)
              add_field("item_#{idx}_unitPrice", item[:unit_price])
              add_field("item_#{idx}_quantity", quantity)
            end
          end
        end
      end
    end
  end
end

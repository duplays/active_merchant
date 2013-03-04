module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module CyberSourceSop
        class Helper < ActiveMerchant::Billing::Integrations::Helper

          mapping :account,  'merchantID'
          mapping :credential2, 'orderPage_serialNumber'
          mapping :transaction_type, 'orderPage_transactionType'

          mapping :order,    'orderNumber'
          mapping :currency, 'currency'
          mapping :amount,   'amount'
          mapping :ignore_avs, 'orderPage_ignoreAVS'
          mapping :version, 'orderPage_version'


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
          mapping :decline_url, 'orderPage_declineResponseURL'

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
            # TODO: require! is not raising exception as expected
            # requires!(options, :credential2)
            [:credential2, :amount, :currency, :shared_secret].each do | key |
              unless options.has_key?(key)
                raise ArgumentError.new("Missing required parameter: #{key}")
              end
            end

            @shared_secret = options.delete(:shared_secret)

            super

            unless options[:transaction_type].present?
              add_field('orderPage_transactionType', 'sale')
            end
            unless options[:ignore_avs].present?
              add_field('orderPage_ignoreAVS', 'true')
            end
            unless options[:version].present?
              add_field('orderPage_version', '7')
            end

            insert_fixed_fields()
            insert_timestamp_field()
            insert_signature_public()
            insert_card_fields()
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

          def insert_timestamp_field
            add_field('orderPage_timestamp', get_microtime)
          end

          def insert_signature_public
            add_field('orderPage_signaturePublic', sop_hash())
          end

          def insert_fixed_fields
            add_field('orderPage_sendMerchantURLPost', 'true')
            add_field('billTo_country', 'na')
            add_field('billTo_city', 'na')
            add_field('billTo_street1', 'na')
          end

          def insert_card_fields
            result = []
            # result << "<input id=\"#{field}\" name=\"#{field}\" type=\"hidden\" value=\"#{value}\" />\n"
            result << "First Name: <input autocomplete=\"off\" type=\"text\" name=\"billTo_firstName\" />\n"
            result= result.join("\n")

            concat(result.respond_to?(:html_safe) ? result.html_safe : result)
          end

          def get_microtime
            t = Time.now
            @time_stamp ||= sprintf("%d%03d", t.to_i, t.usec / 1000)
          end

          # private

          def sop_hash
            Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new,
              @shared_secret, sop_data)).chomp.gsub(/\n/,'')
          end

          def sop_data
            (@fields['merchantID'] +
            @fields['amount'] +
            @fields['currency'] +
            get_microtime() +
            @fields['orderPage_transactionType'])
          end

        end
      end
    end
  end
end

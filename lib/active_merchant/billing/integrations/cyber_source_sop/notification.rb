require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module CyberSourceSop
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          def complete?
            status == 'ACCEPT'
          end

          def item_id
            params['orderNumber']
          end

          def transaction_id
            params['requestID']
          end

          def currency
            params['orderCurrency']
          end

          # When was this payment received by the client.
          def received_at
            Time.strptime(params['ccAuthReply_authorizedDateTime'], '%Y-%m-%dT%H%M%SZ')
          end

          def payer_email
            params['billTo_email']
          end

          def receiver_email
            params['']
          end

          def security_key
            params['']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['orderAmount']
          end

          # Was this a test transaction?
          def test?
            params['orderPage_environment'] == 'TEST'
          end

          def status
            params['decision']
          end

          def missing_fields
            params.select{|key, value| key =~ /^MissingField/}.
              collect{|key, value| value}
          end

          def invalid_fields
            params.select{|key, value| key =~ /^InvalidField/}.
              collect{|key, value| value}
          end

          def reason
            @@response_codes[('r' + reason_code).to_sym]
          end

          def reason_code
            params['reasonCode']
          end

          private

          @@response_codes = {
            :r100 => "Successful transaction",
            :r101 => "Request is missing one or more required fields" ,
            :r102 => "One or more fields contains invalid data",
            :r150 => "General failure",
            :r151 => "The request was received but a server time-out occurred",
            :r152 => "The request was received, but a service timed out",
            :r200 => "The authorization request was approved by the issuing bank but declined by CyberSource because it did not pass the AVS check",
            :r201 => "The issuing bank has questions about the request",
            :r202 => "Expired card",
            :r203 => "General decline of the card",
            :r204 => "Insufficient funds in the account",
            :r205 => "Stolen or lost card",
            :r207 => "Issuing bank unavailable",
            :r208 => "Inactive card or card not authorized for card-not-present transactions",
            :r209 => "American Express Card Identifiction Digits (CID) did not match",
            :r210 => "The card has reached the credit limit",
            :r211 => "Invalid card verification number",
            :r221 => "The customer matched an entry on the processor's negative file",
            :r230 => "The authorization request was approved by the issuing bank but declined by CyberSource because it did not pass the card verification check",
            :r231 => "Invalid account number",
            :r232 => "The card type is not accepted by the payment processor",
            :r233 => "General decline by the processor",
            :r234 => "A problem exists with your CyberSource merchant configuration",
            :r235 => "The requested amount exceeds the originally authorized amount",
            :r236 => "Processor failure",
            :r237 => "The authorization has already been reversed",
            :r238 => "The authorization has already been captured",
            :r239 => "The requested transaction amount must match the previous transaction amount",
            :r240 => "The card type sent is invalid or does not correlate with the credit card number",
            :r241 => "The request ID is invalid",
            :r242 => "You requested a capture, but there is no corresponding, unused authorization record.",
            :r243 => "The transaction has already been settled or reversed",
            :r244 => "The bank account number failed the validation check",
            :r246 => "The capture or credit is not voidable because the capture or credit information has already been submitted to your processor",
            :r247 => "You requested a credit for a capture that was previously voided",
            :r250 => "The request was received, but a time-out occurred with the payment processor",
            :r254 => "Your CyberSource account is prohibited from processing stand-alone refunds",
            :r255 => "Your CyberSource account is not configured to process the service in the country you specified"
          }

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            @raw = post
            for line in post.split('&')
              key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
              params[key] = value
            end
          end
        end
      end
    end
  end
end

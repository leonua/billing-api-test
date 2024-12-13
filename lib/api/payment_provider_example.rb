require 'net/http'
require 'uri'

module Api
  class PaymentProviderExample
    DOMAIN = "https://www.payment.com"

    def initialize
      @headers = {
        'Content-Type': 'application/json'
        # TODO: expand with authorization/verification/etc
      }
    end

    def create(payload)
      result = send_create(payload)

      log(payload, result)

      result
    end

    # TODO: point to sent id to datadog or other logging method
    def log(payload, result)
      Rails.logger.debug("#{self.class.name}::create #{payload.inspect} -> #{result.inspect}")
    end

    def send_create(payload)
      res = Net::HTTP.post(URI("#{DOMAIN}/paymentIntents/create"), payload.to_json, @headers)

      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          JSON.parse(res.body)
        else
          {status: :failed}
      end
    rescue Exception => e
      {status: :failed, exception: e.message}
    end
  end
end
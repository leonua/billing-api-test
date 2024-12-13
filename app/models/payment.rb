class Payment < ApplicationRecord
  belongs_to :subscription

  REPAYMENTS_STEPS = 4 # aka 100%, 75%, 50%, 25%, if changed to `REPAYMENTS_STEPS = 5` - 100%, 80%, 60%...
  DELAY_ON_NO_PAYMENT = 7.days
  DELAY_ON_ERROR = 1.day

  scope :to_pay, ->() { where(process_at: ..Time.zone.now, status: 'active') }

  before_validation :update_status_by_amount

  def update_status_by_amount
    return unless paid_amount_changed?

    if paid_amount == amount
      self.status = 'paid'
    else
      self.process_at = process_at + DELAY_ON_NO_PAYMENT
    end
  end

  # TODO: can be moved to service/concern/sidekiq-job/lib, depends on preffered style, kept it here to have better overview
  # so as idea - `self.pay` can be a sidekiq job, not a method here
  def self.pay
    processed_ids = []
    # TODO: selecting 1 one by one to have better sync with DB in case processing in multilple threads and fetching fresher scheduled payments
    while to_process = Payment.to_pay.where.not(id: processed_ids).first
      # TODO: put id before processing the payment, in case someone mess a code and will create deadllop by not changing status/process_at, and same payment will be selected again
      processed_ids << to_process.id

      to_process.pay
    end
  end

  # TODO: event when payment processing in `self.pay` select payments one-by-one, is better to use DB-pessimistic/redis locking
  # for now I skipped locking code to reduce gems dependencies
  # and probabbly best idea is use lock on `self.pay` too, to have double ensurance that same amounts will not be processed twice
  def pay
    # TODO: payload is kept here becauase can be different per payment provider, but can be moved to own method
    payload = {
      amount: amount_to_send,
      subscription_id: subscription_id
      # currency: ''
      # description: ''
    }

    # TODO: is nice place to choose payment provider by some options, our wrapper should handle same payment_status response format
    payment_status = Api::PaymentProviderExample.new.create(payload)

    case payment_status["status"]
      when "insufficient_funds"
        @to_pay_part = @to_pay_part - 1
        if @to_pay_part > 0 # TODO: recursive part... can be changed to more preffered way
          pay
        else
          update(process_at: process_at + DELAY_ON_NO_PAYMENT)
        end
      when "failed"
        update(process_at: process_at + DELAY_ON_ERROR)
      when "success"
        update(paid_amount: paid_amount + amount_to_send)
    end

    self
  end

  def amount_to_send
    @to_pay_part ||= paid_amount.zero? ? REPAYMENTS_STEPS : (amount - paid_amount) / (amount / REPAYMENTS_STEPS)
    amount / REPAYMENTS_STEPS * @to_pay_part
  end
end
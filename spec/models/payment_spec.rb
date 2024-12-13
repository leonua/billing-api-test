require 'test_helper'
require 'webmock/rspec'

RSpec.describe Payment do
  let(:subscription) { create(:subscription, :active) }

  let(:payment_stub) {
    stub_request(:post, "https://www.payment.com/paymentIntents/create")
  }

  describe 'Payments for active subscription' do
    it 'Simple payment' do
      payment = subscription.schedule_payment!

      payment_stub.
        to_return(status: 200, body: {status: :success}.to_json)

      Payment.pay

      payment.reload

      expect(payment.status).to eq('paid')
      expect(payment.paid_amount).to eq(payment.amount)
    end

    it 'Partially paid' do
      payment = subscription.schedule_payment!

      payment_stub().
        to_return(status: 200, body: {status: :insufficient_funds}.to_json).
        to_return(status: 200, body: {status: :success}.to_json)

      Payment.pay

      payment.reload

      expect(payment.status).to eq('active')
      # TODO: not hardcoded as 882 because if we change Payment::REPAYMENTS_STEPS to other than 4, 882 will also change
      expected_amount = payment.amount / Payment::REPAYMENTS_STEPS * (Payment::REPAYMENTS_STEPS - 1)
      expect(payment.paid_amount).to eq(expected_amount)
    end

    it 'Partially paid first, then paid completely' do
      payment = subscription.schedule_payment!

      payment_stub().
        to_return(status: 200, body: {status: :insufficient_funds}.to_json). # not paid 100%
        to_return(status: 200, body: {status: :success}.to_json). # paid 75%
        to_return(status: 200, body: {status: :success}.to_json) # paid 25%

      Payment.pay

      payment.reload
      expect(payment.status).to eq('active')

      # TODO: not hardcoded as 882 because if we change Payment::REPAYMENTS_STEPS to other than 4, 882 will also change
      expected_amount = payment.amount / Payment::REPAYMENTS_STEPS * (Payment::REPAYMENTS_STEPS - 1)
      expect(payment.paid_amount).to eq(expected_amount)

      # TODO: because `insufficient_funds` move it to next week, but we simulate that time is passed
      payment.update(process_at: 1.minute.ago)

      Payment.pay

      payment.reload

      expect(payment.status).to eq('paid')
      expect(payment.paid_amount).to eq(payment.amount)
    end

    it 'Partially paid half, then paid completely' do
      payment = subscription.schedule_payment!

      payment_stub().
        to_return(status: 200, body: {status: :insufficient_funds}.to_json). # not paid 100%
        to_return(status: 200, body: {status: :insufficient_funds}.to_json). # not paid 100%
        to_return(status: 200, body: {status: :success}.to_json). # paid 50%
        to_return(status: 200, body: {status: :success}.to_json) # paid 50%

      Payment.pay

      payment.reload
      expect(payment.status).to eq('active')

      # TODO: not hardcoded as 882 because if we change Payment::REPAYMENTS_STEPS to other than 4, 882 will also change
      expected_amount = payment.amount / Payment::REPAYMENTS_STEPS * (Payment::REPAYMENTS_STEPS - 2)
      expect(payment.paid_amount).to eq(expected_amount)

      # TODO: because `insufficient_funds` move it to next week, but we simulate that time is passed
      payment.update(process_at: 1.minute.ago)

      Payment.pay

      payment.reload

      expect(payment.status).to eq('paid')
      expect(payment.paid_amount).to eq(payment.amount)
    end

    it 'Nothing is paid, moved to next week' do
      payment = subscription.schedule_payment!

      payment_stub().
        to_return(status: 200, body: {status: :insufficient_funds}.to_json). # not paid 100%
        to_return(status: 200, body: {status: :insufficient_funds}.to_json). # not paid 100%
        to_return(status: 200, body: {status: :insufficient_funds}.to_json). # not paid 100%
        to_return(status: 200, body: {status: :insufficient_funds}.to_json) # not paid 100%

      Payment.pay

      payment.reload
      expect(payment.status).to eq('active')
      expect(payment.process_at.to_date).to eq(Date.today + Payment::DELAY_ON_NO_PAYMENT)
    end
  end

  describe 'Errors handling' do
    it 'Error 500, then paid' do
      payment = subscription.schedule_payment!

      payment_stub().
        to_return(status: 500).
        to_return(status: 200, body: {status: :success}.to_json)

      Payment.pay

      # TODO: because `500` move it to next day, but we simulate that time is passed
      payment.update(process_at: 1.minute.ago)

      Payment.pay

      payment.reload

      expect(payment.status).to eq('paid')
      expected_amount = payment.amount
      expect(payment.paid_amount).to eq(expected_amount)
    end

    it 'Exception from service, then paid' do
      payment = subscription.schedule_payment!

      payment_stub().
        to_raise(StandardError.new("some error")).
        to_return(status: 200, body: {status: :success}.to_json)

      Payment.pay

      # TODO: because `500` move it to next day, but we simulate that time is passed
      payment.update(process_at: 1.minute.ago)

      Payment.pay

      payment.reload

      expect(payment.status).to eq('paid')
      expected_amount = payment.amount
      expect(payment.paid_amount).to eq(expected_amount)
    end

    it 'Timeout from service, then paid' do
      payment = subscription.schedule_payment!

      payment_stub().
        to_timeout.
        to_return(status: 200, body: {status: :success}.to_json)

      Payment.pay

      # TODO: because `500` move it to next day, but we simulate that time is passed
      payment.update(process_at: 1.minute.ago)

      Payment.pay

      payment.reload

      expect(payment.status).to eq('paid')
      expected_amount = payment.amount
      expect(payment.paid_amount).to eq(expected_amount)
    end

  end

end

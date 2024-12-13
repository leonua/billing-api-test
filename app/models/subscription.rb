class Subscription < ApplicationRecord
  has_one :payment

  def schedule_payment!
    # TODO: the earlier we covnert float to cents - the better
    build_payment(process_at: Time.zone.now, amount: price * 100).save!
    # TODO: return built object to have it for possible reuse
    payment
  end
end
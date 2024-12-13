FactoryBot.define do
  factory :subscription do
    trait :active do
      start_at { Time.zone.now.to_date }
      end_at { (Time.zone.now + 2.weeks).to_date }
      price { 11.76 }
    end
  end
end

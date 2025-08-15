FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    verified { false }

    trait :verified do
      verified { true }
    end

    trait :unverified do
      verified { false }
    end
  end
end

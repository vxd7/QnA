FactoryBot.define do
  factory :answer do
    body { "MyString" }
    association :question
  end

  trait :invalid do
    body { nil }
  end
end

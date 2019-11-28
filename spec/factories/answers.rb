FactoryBot.define do
  factory :answer do
    body { "MyString" }
    question
  end

  trait :invalid do
    body { nil }
  end
end

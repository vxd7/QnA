FactoryBot.define do
  factory :answer do
    body { "AnswerBody" }
    question
    association :author, factory: :user
  end

  trait :invalid do
    body { nil }
  end
end

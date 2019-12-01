FactoryBot.define do
  factory :answer do
    body { "AnswerBody" }
    question
  end

  trait :invalid do
    body { nil }
  end
end

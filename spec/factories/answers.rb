FactoryBot.define do
  factory :answer do
    body { "AnswerBody" }
    question
    association :author, factory: :user
  end

  trait :invalid do
    body { nil }
  end

  trait :different do
    sequence :body do |n|
      "AnswerBody#{n}"
    end
  end
end

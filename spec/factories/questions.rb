FactoryBot.define do
  factory :question do
    title { "QuestionTitle" }
    body { "QuestionBody" }
    association :author, factory: :user

    trait :invalid do
      title { nil }
    end

    trait :different do
      sequence :title do |n|
        "QuestionTitle#{n}"
      end

      sequence :body do |n|
        "QuestionBody#{n}"
      end
    end
  end
end

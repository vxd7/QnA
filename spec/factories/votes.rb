FactoryBot.define do
  factory :vote do
    user
    value {1}

    trait :question do
      association :voteable, factory: :question
    end

    trait :answer do
      association :voteable, factory: :answer
    end

    trait :positive_vote do
      value {1}
    end

    trait :negative_vote do
      value {-1}
    end
  end
end

FactoryBot.define do
  factory :comment do
    user
    body { 'MyBody' }

    trait :different do
      sequence :body do |n|
        "MyCommentBody#{n}"
      end
    end

    trait :question do
      association :linkable, factory: :question
    end

    trait :answer do
      association :linkable, factory: :answer
    end
  end
end

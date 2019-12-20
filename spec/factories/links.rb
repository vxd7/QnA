FactoryBot.define do
  factory :link do
    name { "MyLinkName" }
    url { "http://test.com" }

    trait :question do
      association :linkable, factory: :question
    end

    trait :answer do
      association :linkable, factory: :answer
    end

    trait :different do
      sequence :name do |n|
        "MyLinkName#{n}"
      end

      sequence :url do |n|
        "http://test#{n}.com"
      end
    end
  end
end

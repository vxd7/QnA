FactoryBot.define do
  factory :question do
    title { "MyString" }
    body { "MyText" }

    trait :invalid do
      title { nil }
    end

    trait :different do
      sequence :title do |n|
        "Title#{n}"
      end

      sequence :body do |n|
        "Text#{n}"
      end
    end
  end
end

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

    trait :with_files do
      files { [Rack::Test::UploadedFile.new("#{Rails.root}/spec/rails_helper.rb", 'text/plain'),
               Rack::Test::UploadedFile.new("#{Rails.root}/spec/spec_helper.rb", 'text/plain')] }
    end

    trait :with_links do
      after(:create) do |q|
        create_list(:link, 3, :different, linkable: q)
      end
    end
  end
end

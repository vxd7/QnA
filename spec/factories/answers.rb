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

  trait :with_files do
    files { [Rack::Test::UploadedFile.new("#{Rails.root}/spec/rails_helper.rb", 'text/plain'),
             Rack::Test::UploadedFile.new("#{Rails.root}/spec/spec_helper.rb", 'text/plain')] }
  end
end

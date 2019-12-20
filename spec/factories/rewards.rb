FactoryBot.define do
  factory :reward do
    name { "MyReward" }
    question
    user { nil }
    image { Rack::Test::UploadedFile.new("#{Rails.root}/public/reward.png", "image/png") }

  end
end

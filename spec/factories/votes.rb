FactoryBot.define do
  factory :vote do
    user { nil }
    value { 1 }
    voteable { "" }
  end
end

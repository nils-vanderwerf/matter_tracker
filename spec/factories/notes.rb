FactoryBot.define do
  factory :note do
    body { "Test note body" }
    association :matter
  end
end

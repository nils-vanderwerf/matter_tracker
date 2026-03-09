FactoryBot.define do
  factory :matter do
    title { "Test Matter" }
    matter_type { "Commercial" }
    status { "Open" }
    due_date { Date.today + 30 }
    association :client
  end
end

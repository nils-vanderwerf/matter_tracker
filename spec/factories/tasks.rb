FactoryBot.define do
  factory :task do
    title { "Test Task" }
    status { "Pending" }
    priority { "Medium" }
    association :matter
  end
end

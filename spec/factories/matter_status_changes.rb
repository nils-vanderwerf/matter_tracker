FactoryBot.define do
  factory :matter_status_change do
    association :matter
    status { "Open" }
  end
end

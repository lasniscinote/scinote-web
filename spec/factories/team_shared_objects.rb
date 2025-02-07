# frozen_string_literal: true

# frozen_string_literal: true

FactoryBot.define do
  factory :team_shared_object do
    repository
    trait :read do
      permission_level { :shared_read }
    end
    trait :write do
      permission_level { :shared_write }
    end
  end
end

FactoryGirl.define do
  to_create(&:save)

  factory :seed do
    term 'seed'
    created_at Time.now
    updated_at Time.now
  end

  trait :planted_31_days_ago do
    last_planted((Time.now - (31 * 24 * 60 * 60)))
  end
end

FactoryGirl.define do
  to_create(&:save)

  factory :seed do
    term 'seed'
    created_at Time.now
    updated_at Time.now
  end
end

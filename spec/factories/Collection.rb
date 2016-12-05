FactoryGirl.define do
  factory :collection do
    tag        { Faker::Pokemon.name.downcase.gsub(/\s+/, "") }
    name       { tag.capitalize + ' Images' }
    end_date   { Faker::Date.between(1.days.ago, Date.today) }
    start_date { Faker::Date.between(3.days.ago, end_date - 1.days) }
    is_public  { Faker::Boolean.boolean }

    trait :private do
      is_public false
    end

    trait :public do
      is_public true
    end

    factory :collection_private, traits: [:private]
    factory :collection_public,  traits: [:public]

    before(:create) do |me, vals|
      me.unique_url = SecureRandom.urlsafe_base64(24)
    end
  end
end

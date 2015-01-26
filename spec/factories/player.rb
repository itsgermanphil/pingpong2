FactoryGirl.define do
  sequence :name do |n|
    "User #{n}"
  end

  sequence :email do |n|
    "test_user_#{n}@example.com"
  end

  sequence :uid do |n|
    n
  end

  factory :player do
    uid
    name
    email
  end

  factory :round do
    start_date Time.now - 1.day
  end
end

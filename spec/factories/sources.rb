FactoryBot.define do
  factory :source do
    name { "source name" }
  end
  factory :user_source, class: "UserSource" do
    user { create(:user) }
  end
end

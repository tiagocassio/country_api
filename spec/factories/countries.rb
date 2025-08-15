FactoryBot.define do
  factory :country do
    name {  Faker::WorldCup.team }
    alpha2_code { Faker::Address.country_code }
    alpha3_code { Faker::Address.country_code_long }
    official_name {  Faker::WorldCup.team }
    capital { Faker::Name.name }
    region { Faker::Name.name }
    subregion { Faker::Name.name }
    population { Faker::Number.between(from: 1, to: 99999999999) }
    area { "Area #{Faker::Number.between(from: 1, to: 9999999999)}" }
    currencies { Faker::Currency.name }
    language { Faker::WorldCup.team }
    calling_code { Faker::PhoneNumber.country_code }
    time_zones { Faker::Address.time_zone }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    borders { nil }
    flag { Faker::Internet.url(host: "https://flagcdn.com/256x192/#{Faker::Address.country_code.downcase}.png") }
    slug { nil }
  end
end

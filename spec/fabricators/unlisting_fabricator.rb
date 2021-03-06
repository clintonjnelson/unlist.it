Fabricator(:unlisting) do
  title         { "#{Faker::Lorem.word}" }
  description   { "#{Faker::Lorem.sentence}" }
  price         { Faker::Number.number(2) }
  keyword1      { "#{Faker::Lorem.word}" }
  keyword2      { "#{Faker::Lorem.word}" }
  keyword3      { "#{Faker::Lorem.word}" }
  keyword4      { "#{Faker::Lorem.word}" }
  link          { "http://www.google.com" }
  travel        { true }
  distance      { [5, 10, 25, 50, 75, 100, 200, 500].sample}
  zipcode       { 98164 }

  creator
  category
  condition
end

Fabricator(:condition) do
  level       { "#{ Faker::Name.name }" }
  position    { "#{ Faker::Number.number(3) }" }
end

Fabricator(:condition_with_category, from: :condition) do
  categories(count: 3) { Fabricate(:category) }
end

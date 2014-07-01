Fabricator(:condition) do
  level       { "#{ Faker::Name.name }" }
  position    { "#{ Faker::Number.number(5) }" }
end

Fabricator(:condition_with_category, from: :condition) do
  categories(count: 3) { Fabricate(:category) }
end

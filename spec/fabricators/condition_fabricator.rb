Fabricator(:condition) do
  level       { %w[ poor fair good excellent perfect new ].sample }
  order       { "#{ Faker::Number.number(3) }" }
end

Fabricator(:condition_with_category, from: :condition) do
  categories(count: 3) { Fabricate(:category) }
end

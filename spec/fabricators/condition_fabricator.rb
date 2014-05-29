Fabricator(:condition) do
  level       { %w[ poor fair good excellent perfect new ].sample }
end

Fabricator(:condition_with_category, from: :condition) do
  categories(count: 3) { Fabricate(:category) }
end

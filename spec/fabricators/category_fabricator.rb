Fabricator(:category) do
  name  { %w[ autos boats housewares materials tools ].sample }
end

Fabricator(:category_with_condition, from: :category) do
  conditions(count: 3) { Fabricate(:condition) }
end

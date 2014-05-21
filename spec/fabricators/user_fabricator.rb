Fabricator(:user) do
  email     { "#{Faker::Internet.safe_email}" }
  name      { "#{Faker::Name.name}" }
  password  "password"
end

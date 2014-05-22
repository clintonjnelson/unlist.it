Fabricator(:user) do
  email         { "#{Faker::Internet.safe_email}" }
  username      { "#{Faker::Name.name}" }
  password      "password"
end

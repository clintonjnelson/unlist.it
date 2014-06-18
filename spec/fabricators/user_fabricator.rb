Fabricator(:user, aliases: [:creator, :sender, :recipient]) do
  email           { "#{Faker::Internet.safe_email}" }
  username        { "#{Faker::Name.name}" }
  password        "password"
  prt             nil
  prt_created_at  { 1.day.ago }
end

Fabricator(:admin, from: :user) do
  role "admin"
end


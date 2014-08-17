Fabricator(:user, aliases: [:creator, :sender, :recipient]) do
  email           { "#{Faker::Internet.safe_email}" }
  password        "password"
  prt             nil
end

Fabricator(:admin, from: :user) do
  role "admin"
end


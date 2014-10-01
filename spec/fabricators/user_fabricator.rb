Fabricator(:user, aliases: [:creator, :sender, :recipient]) do
  email           { "#{Faker::Internet.safe_email}" }
  password        "password"
  prt             nil
  termsconditions { Time.now }
end

Fabricator(:admin, from: :user) do
  role "admin"
end


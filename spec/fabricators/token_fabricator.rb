Fabricator(:token) do
  token {"#{Faker::Bitcoin.address}"}
  creator(fabricator: :user)
end

Fabricator(:user_token, from: :token) do
  tokenable_type {"User"}
  tokenable_id {"1"}
end

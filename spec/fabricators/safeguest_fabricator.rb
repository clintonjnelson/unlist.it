Fabricator(:safeguest) do
  email           { "#{Faker::Internet.safe_email}" }
  confirmed         false
  blacklisted       false
end

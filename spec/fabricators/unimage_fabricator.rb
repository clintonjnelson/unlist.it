Fabricator(:unimage) do
  filename  { "#{ Faker::Internet.url('example.com') }" }
  token     { "1234abcd" }
  unlisting
end

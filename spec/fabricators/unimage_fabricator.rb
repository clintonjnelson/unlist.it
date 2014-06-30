Fabricator(:unimage) do
  filename  { "#{ Faker::Internet.url('example.com') }" }

  unpost
end

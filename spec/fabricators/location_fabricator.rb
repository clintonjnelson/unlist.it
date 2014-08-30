Fabricator(:location) do
  zipcode        98164
end

Fabricator(:zip_location, from: :location) do
  latitude       47.6062095
  longitude      -122.3320708
  zipcode        98164
end

Fabricator(:city_state_location, from: :location) do
  latitude       47.606503
  longitude      -122.3323955
  city           "seattle"
  state          "wa"
end

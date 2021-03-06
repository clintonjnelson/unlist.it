Fabricator(:message) do
  subject { "#{ Faker::Lorem.words(3) }" }
  content { "#{ Faker::Lorem.sentence }" }
end

Fabricator(:user_unlisting_message, from: :message) do
  messageable_type  "Unlisting"
  messageable_id    1
  sender
  recipient
end

Fabricator(:guest_unlisting_message, from: :message) do
  contact_email     { "#{ Faker::Internet.safe_email }" }
  messageable_type  "Unlisting"
  messageable_id    1
  recipient
end

Fabricator(:reply_message, from: :message) do
  messageable_type  "Message"
  messageable_id    1
  sender
  recipient
end

Fabricator(:user_message, from: :message) do
  messageable_type  "User"
  messageable_id    1
  sender
  recipient
end

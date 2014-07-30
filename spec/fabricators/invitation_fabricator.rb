Fabricator(:invitation) do
  recipient_email       { "#{Faker::Internet.safe_email}" }
  token                 { "#{SecureRandom.urlsafe_base64}" }

  sender
end


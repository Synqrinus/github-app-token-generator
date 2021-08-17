require 'openssl'
require 'jwt'

private_key = ENV.fetch('PRIVATE_KEY')
app_id = ENV.fetch('APP_ID')
lifetime_minutes = ENV.fetch('LIFETIME_MINUTES')

puts JWT.encode({
  iat: Time.now.to_i,
  exp: Time.now.to_i + (lifetime_minutes.to_i * 60),
  iss: app_id
}, OpenSSL::PKey::RSA.new(private_key), 'RS256')

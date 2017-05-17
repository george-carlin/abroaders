Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :facebook,
    ENV['FACEBOOK_APP_ID'],
    ENV['FACEBOOK_APP_SECRET'],
    scope: 'public_profile,email',
    info_fields: 'first_name,email',
  )
end

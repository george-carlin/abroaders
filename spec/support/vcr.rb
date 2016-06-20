VCR.configure do |config|
  config.cassette_library_dir = Rails.root.join("spec", "support", "vcr_cassettes")
  config.hook_into :webmock
  config.ignore_localhost = true
end

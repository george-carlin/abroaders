# Auth.setup do |config|
#   config.secret_key = ENV["DEVISE_SECRET_KEY"]
#   config.allow_unconfirmed_access_for = nil
#   config.reconfirmable = true
#   config.scoped_views = true
#   config.sign_out_via = :delete
#
#   config.warden do |manager|
#     manager.strategies.clear!
#     manager.strategies.add(:database_authenticatable, Auth::Strategies::DatabaseAuthenticatable)
#     manager.strategies.add(:rememberable, Auth::Strategies::Rememberable)
#
#     ds = [:rememberable, :database_authenticatable]
#     manager[:default_strategies] = { account: ds.dup, admin: ds.dup }
#   end
# end

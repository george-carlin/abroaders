class Admin < ApplicationRecord
  include Auth::Models::Authenticatable
  include Auth::Models::DatabaseAuthenticatable
  include Auth::Models::Rememberable
  include Auth::Models::Recoverable
  include Auth::Models::Registerable
  include Auth::Models::Validatable
  include Auth::Models::Trackable
end

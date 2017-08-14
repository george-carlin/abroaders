require 'auth'
require 'bcrypt'

module Auth
  module Encryptor
    def self.digest(password)
      ::BCrypt::Password.create(password, cost: Auth.stretches).to_s
    end

    def self.compare(hashed_password, password)
      return false if hashed_password.blank?
      bcrypt = ::BCrypt::Password.new(hashed_password)
      password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)
      Auth.secure_compare(password, hashed_password)
    end
  end
end

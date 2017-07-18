require 'auth'
require 'bcrypt'

module Auth
  module Encryptor
    # DEVISETODO do these two methods still need to received the 'klass' arg?

    def self.digest(klass, password)
      ::BCrypt::Password.create(password, cost: klass.stretches).to_s
    end

    def self.compare(_klass, hashed_password, password)
      return false if hashed_password.blank?
      bcrypt = ::BCrypt::Password.new(hashed_password)
      password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)
      Auth.secure_compare(password, hashed_password)
    end
  end
end

require 'auth'
require 'bcrypt'

module Auth
  module Encryptor
    def self.digest(klass, password)
      password = "#{password}#{klass.pepper}" if klass.pepper.present?
      ::BCrypt::Password.create(password, cost: klass.stretches).to_s
    end

    def self.compare(klass, hashed_password, password)
      return false if hashed_password.blank?
      bcrypt = ::BCrypt::Password.new(hashed_password)
      password = "#{password}#{klass.pepper}" if klass.pepper.present?
      password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)
      Auth.secure_compare(password, hashed_password)
    end
  end
end

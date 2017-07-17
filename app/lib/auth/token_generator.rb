require 'openssl'

module Auth
  class TokenGenerator
    DIGEST = 'SHA256'.freeze

    def initialize(key_generator)
      @key_generator = key_generator
    end

    def digest(_klass, column, value)
      value.present? && OpenSSL::HMAC.hexdigest(DIGEST, key_for(column), value.to_s)
    end

    def generate(klass, column)
      key = key_for(column)

      loop do
        raw = Auth.friendly_token
        enc = OpenSSL::HMAC.hexdigest(DIGEST, key, raw)
        break [raw, enc] unless klass.find_by(column => enc)
      end
    end

    private

    def key_for(column)
      # TODO can the word 'Devise' be removed here?
      @key_generator.generate_key("Devise #{column}")
    end
  end
end

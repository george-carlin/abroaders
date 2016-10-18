module IntercomEventName
  ONBOARDING_SURVEY_PREFIX = "obs".freeze
  OWNER_SUFFIX             = "own".freeze
  COMPANION_SUFFIX         = "com".freeze

  def self.create(*keys)
    keys = keys.map(&:to_s)

    if keys.first == "onboarding"
      keys.shift
      name << ONBOARDING_SURVEY_PREFIX
    end

    last =  keys.pop
    name += keys

    name << if last == "companion"
              COMPANION_SUFFIX
            elsif last == "owner"
              OWNER_SUFFIX
            else
              last
            end
  end
end

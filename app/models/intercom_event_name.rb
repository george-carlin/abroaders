module IntercomEventName

  ONBOARDING_SURVEY_PREFIX = "obs"
  OWNER_SUFFIX             = "own"
  COMPANION_SUFFIX         = "com"

  def self.create(*keys)
    keys = keys.map(&:to_s)

    if keys.first == "onboarding"
      keys.shift
      name << ONBOARDING_SURVEY_PREFIX
    end

    last =  keys.pop
    name += keys

    if last == "companion"
      name << COMPANION_SUFFIX
    elsif last == "owner"
      name << OWNER_SUFFIX
    else
      name << last
    end
  end

end

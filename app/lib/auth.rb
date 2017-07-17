module Auth
  def mappings
    Devise.mappings
  end

  # Small method that adds a mapping to Auth.
  def self.add_mapping(resource, options = {})
    Devise.add_mapping(resource, options)
  end
end

require 'warden'

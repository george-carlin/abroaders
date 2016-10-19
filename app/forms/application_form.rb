# For a detailed explanation of form objects and how they work, see
# `app/forms/README.md`.
class ApplicationForm
  extend  ActiveModel::Naming
  include ActiveModel::Model
  include Virtus.model(nullify_blank: true)
  include I18nWithErrorRaising

  def self.create(*attrs)
    instance = new(*attrs)
    instance.save
    instance
  end

  def self.create!(*attrs)
    instance = new(*attrs)
    instance.save!
    instance
  end

  def initialize(attributes = nil)
    # Virtus will call `attributes.to_hash`, but this will raise a warning
    # if attributes is an `ActionController::Parameters`. Avoid
    # this warning by calling `to_h` instead:
    super(attributes&.to_h)
  end

  # If you're creating a Form object for *editing* a record rather than
  # creating a new one, you should override `persisted?` so that it returns
  # true.
  def persisted?
    false
  end

  def self.transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end

  def transaction(&block)
    self.class.transaction(&block)
  end

  def save
    transaction do
      if valid?
        persist!
        true
      else
        false
      end
    end
  end

  def save!
    if save
      true
    else
      raise ActiveRecord::RecordInvalid.new, self
    end
  end

  def assign_attributes(attributes)
    attributes.each do |key, value|
      send "#{key}=", value
    end
  end

  def update(attributes)
    assign_attributes(attributes)
    save
  end
  alias update_attributes update

  def update!(attributes)
    return true if update_attributes(attributes)
    raise ActiveRecord::RecordInvalid.new, errors.full_messages.join(", ")
  end
  alias update_attributes! update!

  private

  def persist!
    raise NotImplementedError, "subclasses of ApplicationForm must define a method called `persist!`"
  end
end

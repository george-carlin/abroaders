# For a detailed explanation of form objects and how they work, see
# `app/forms/README.md`.
class ApplicationForm
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
      raise ActiveRecord::RecordInvalid.new(errors.full_messages.join(", "))
    end
  end

  def assign_attributes(attributes)
    attributes.each do |key, value|
      self.send "#{key}=", value
    end
  end

  def update(attributes)
    assign_attributes(attributes)
    save
  end
  alias_method :update_attributes, :update

  def update!(attributes)
    if update_attributes(attributes)
      true
    else
      raise ActiveRecord::RecordInvalid.new(errors.full_messages.join(", "))
    end
  end
  alias_method :update_attributes!, :update!

  private

  def persist!
    raise NotImplementedError, "subclasses of ApplicationForm must define a method called `persist!`"
  end

end

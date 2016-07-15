class ApplicationForm
  include ActiveModel::Model
  include I18nWithErrorRaising

  # An empty checkbox in Rails submits "0", while a radio button with
  # value 'false' submits "false" (a string, not a bool) - both of which Ruby
  # will treat as truthy - so use this class method. It acts like attr_accessor,
  # except the *setter* method will cast its arguments to boolean values,
  # treating "false" and "0" as `false`.
  #
  # Also add a 'boolean?' getter method just for good measure.
  def self.attr_boolean_accessor(*attrs)
    attrs.each do |attr|
      attr_reader attr
      alias_method :"#{attr}?", attr

      define_method :"#{attr}=" do |bool|
        instance_variable_set(
          :"@#{attr}",
          (%w[false 0].include?(bool) ? false : !!bool)
        )
      end
    end
  end

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

  # A form object is never persisted
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

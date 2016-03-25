class Form
  include ActiveModel::Model

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
        yield
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

  def update_attributes(attributes)
    assign_attributes(attributes)
    save
  end

  def update_attributes!(attributes)
    if update_attributes(attributes)
      true
    else
      raise ActiveRecord::RecordInvalid.new(errors.full_messages.join(", "))
    end
  end

end

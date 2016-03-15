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

  def assign_attributes(attributes)
    raise NotImplementedError, "subclasses must define #assign_attributes"
  end

  def update_attributes(attributes)
    assign_attributes(attributes)
    save
  end

end

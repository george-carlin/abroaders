class ApplicationService

  def self.transaction(&block)
    ApplicationRecord.transaction(&block)
  end

  def transaction(&block)
    self.class.transaction(&block)
  end

end

class EditAllianceForm < AllianceForm
  attribute :id

  def self.find(id)
    new(::Alliance.find(id).attributes)
  end

  def persisted?
    true
  end

  private

  def persist!
    Alliance.create!(name: name)
  end
end

class EditAllianceForm < AllianceForm
  attribute :id

  def self.find(id)
    new(::Alliance.find(id).attributes)
  end

  def persisted?
    true
  end

  def alliance
    @alliance ||= Alliance.find(id)
  end

  private

  def persist!
    alliance.update!(alliance_params)
  end
end

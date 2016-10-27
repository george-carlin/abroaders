class NewAllianceForm < AllianceForm
  private

  def persist!
    ::Alliance.create!(name: name)
  end
end

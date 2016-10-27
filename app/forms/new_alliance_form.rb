class NewAllianceForm < AllianceForm
  private

  def persist!
    ::Alliance.create!(alliance_params)
  end
end

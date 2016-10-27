class AllianceForm < ApplicationForm
  attribute :name, String

  def self.name
    "Alliance"
  end

  # Validations

  validates :name, presence: true

  private

  def alliance_params
    {
      name: name,
    }
  end
end

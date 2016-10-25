class CurrencySerializer < ApplicationSerializer
  attributes :id, :name, :alliance_id, :full_name

  def name
    object.name.sub(/\s+\(.*\)\s*/, '')
  end

  def full_name
    object.name
  end
end

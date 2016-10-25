class CurrencySerializer < ApplicationSerializer
  attributes :id, :name, :alliance_id

  def name
    object.name.sub(/\s+\(.*\)\s*/, '')
  end
end

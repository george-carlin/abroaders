module SerializerHelper

  def serialize(models)
    # FIXME this is non-API behaviour and extremely hacky. Ugh.
    ActiveModel::Serializer::Adapter::JsonApi.new(
      ActiveModel::Serializer::ArraySerializer.new(models)
    ).as_json
  end

end

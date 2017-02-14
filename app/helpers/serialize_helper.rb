module SerializeHelper
  # Takes a model and returns it serialized in JSON form using the appropriate
  # ActiveModel::Serializer class.
  #
  # This method is semi-deprecated since I want to move away from AM::S and
  # start using representable instead, but removing the old serializer classes
  # is very low priority.
  def serialize(model, serializer_class = nil)
    klass = model.to_model.class
    serializer_class ||= begin
                           "#{klass}::Serializer".constantize
                         rescue NameError # FIXME
                           # Not an ideal solution, but as we move towards a
                           # TRB-style 'concepts' file structure, eventually we
                           # should no longer need this rescue clause... maybe.
                           "#{klass}Serializer".constantize
                         end
    serializer_class.new(model).to_json
  end
end

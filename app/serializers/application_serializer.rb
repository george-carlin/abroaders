class ApplicationSerializer < ActiveModel::Serializer

  # Always include an associated model without having to manually say 'include'
  # in the controller every time. From
  # github.com/rails-api/active_model_serializers/pull/1845#issuecomment-247843653
  def self.always_include(name, options = {})
    attribute(name, options)
    define_method name do
      if obj = object.send(name)
        resource = ActiveModelSerializers::SerializableResource.new(obj)
        resource.serialization_scope = instance_options[:scope]
        resource.serialization_scope_name = instance_options[:scope_name]
        resource.serializable_hash
      end
    end
  end

end

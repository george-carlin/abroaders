class Destination::Representer < Representable::Decorator
  include Representable::JSON

  property :id
  property :name
  property :code
  property :parent_id
  property :parent_name, exec_context: :decorator
  property :parent_code, exec_context: :decorator

  def parent_code
    represented.parent&.code
  end

  def parent_name
    represented.parent&.name
  end
end

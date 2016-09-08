class FakeDBModel
  include Virtus.model
  include ActiveModel::Serializers::JSON

  attribute :id, Fixnum

  def self.find(id)
    find_by(id: id)
  end

  def self.all
    self::TABLE.map { |row| find(row[0]) }
  end

  def self.first
    all.first
  end

  def self.last
    all.last
  end

  def self.inspect
    attr_list = attribute_set.map { |attr| "#{attr.name}: #{attr.primitive}" } * ", "
    %[#<#{self} #{attr_list}">]
  end

  # Returns true if +comparison_object+ is the same exact object, or +comparison_object+
  # is of the same type and +self+ has an ID and it is equal to +comparison_object.id+.
  def ==(comparison_object)
    super ||
        comparison_object.instance_of?(self.class) &&
            !id.nil? &&
            comparison_object.id == id
  end
  alias :eql? :==

  # Delegates to id in order to allow two records of the same type and id to work with something like:
  # [ Model.find(1), Model.find(2), Model.find(3) ] & [ Model.find(1), Model.find(4) ] # => [ Model.find(1) ]
  def hash
    if id
      id.hash
    else
      super
    end
  end

  def <=>(other_object)
    if other_object.is_a?(self.class)
      self.to_key <=> other_object.to_key
    else
      super
    end
  end

  # Returns this record's primary key value wrapped in an array if one is
  # available.
  def to_key
    key = self.id
    [key] if key
  end

  def attributes
    # Virtus's 'attributes' method returns a hash with symbol keys, but
    # ActiveRecord::Base#attributes uses string keys. Keep things consistent:
    super.stringify_keys
  end

  def inspect
    attr_list = attributes.map { |name, value| "#{name}: #{value}" } * ", "
    %[#<#{self.class} #{attr_list}">]
  end

  def has_attribute?(name)
    self.attributes.map{|attr| attr[0]}.include?(name.to_s)
  end

  def to_param
    if has_attribute?(:name)
      name.downcase.parameterize.underscore
    else
      super
    end
  end
end

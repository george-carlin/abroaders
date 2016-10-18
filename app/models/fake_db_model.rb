# A model which looks and talks like an ActiveRecord model, but isn't actually
# backed up by a DB table. Instead the data is hard-coded into the Ruby using a
# constant called TABLE.
#
# FakeDBModel is used for some classes where the data is simple and will almost
# never change. Hardcoding everything into the Ruby reduces the overhead of
# having to load the data from the DB every time.
#
# See also ApplicationRecord#belongs_to_fake_db_model
class FakeDBModel
  include Virtus.model
  include ActiveModel::Serializers::JSON

  attribute :id, Integer

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

  # Returns true if +other+ is the same exact object, or +other+ is of the same
  # type and +self+ has an ID and it is equal to +other.id+.
  def ==(other)
    super || other.instance_of?(self.class) && !id.nil? && other.id == id
  end
  alias eql? ==

  # Delegates to id in order to allow two records of the same type and id to work with something like:
  # [ Model.find(1), Model.find(2), Model.find(3) ] & [ Model.find(1), Model.find(4) ] # => [ Model.find(1) ]
  def hash
    if id
      id.hash
    else
      super
    end
  end

  def <=>(other)
    if other.is_a?(self.class)
      to_key <=> other.to_key
    else
      super
    end
  end

  # Returns this record's primary key value wrapped in an array if one is
  # available.
  def to_key
    key = id
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
    attributes.map { |attr| attr[0] }.include?(name.to_s)
  end

  def to_param
    if has_attribute?(:name)
      name.downcase.parameterize.underscore
    else
      super
    end
  end
end

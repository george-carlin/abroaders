class FakeDBModel
  include Virtus.model
  include ActiveModel::Serializers::JSON

  attribute :id, Fixnum
  attribute :name, String

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

  def ==(other_object)
    other_object.is_a?(self.class) && other_object.id == id
  end

  def <=>(other_object)
    id <=> other_object.id
  end

  # Hash equality. Must return a fixnum that is always the same for identical objects:
  def hash
    Digest::MD5.new.hexdigest("#{id}#{name}")[0..15].to_i(16)
  end

  def eql?(other_object)
    self == other_object && hash == other_object.hash
  end

  def attributes
    # Virtus's 'attributes' method returns a hash with symbol keys, but
    # ActiveRecord::Base#attributes uses string keys. Keep things consistent:
    super.stringify_keys
  end

  def inspect
    %[#<#{self.class} id: #{id}, name: "#{name}">]
  end

  def to_param
    name.downcase.parameterize.underscore
  end
end

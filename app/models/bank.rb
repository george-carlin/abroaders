# Identity object. Since the list of Banks is small, will rarely change, and
# has very little information to store about each bank, a full-blown
# database-backed model is overkill. Instead the list of Banks is stored as a
# constant (TABLE) and Bank has a minimal set of methods to make it quack like
# an ActiveRecord model as far as Card is concerned (so we can get methods like
# Card#bank, Bank.find(id).cards, etc)
class Bank

  attr_reader :id, :name

  # Note that only odd numbers are used for card IDs. This is because each card
  # has a deterministically-generated unique identifier which starts with a
  # number that represents the bank - but there are two numbers per bank, one
  # for personal cards are one for business cards. We're using odd numbers for
  # personal and even numbers for business - so e.g. a Chase personal card's
  # identifier will start with '01' while a Chase business card's identifier
  # will start with '02'
  TABLE =  {
    1  => "Chase",
    3  => "Citibank",
    5  => "Barclays",
    7  => "American Express",
    9  => "Capital One",
    11 => "Bank of America",
    13 => "US Bank",
    15 => "Discover",
    17 => "Diners Club",
    19 => "SunTrust",
    21 => "TD Bank",
    23 => "Wells Fargo",
  }

  class << self
    alias_method :find, :new
  end

  def self.all
    TABLE.map { |id, _| new(id) }
  end

  def self.first
    all.first
  end

  def self.last
    all.last
  end

  # There's only one column that can be sorted by, so the 'column' parameter is
  # rather redundant here - but allow it anyway so that Bank quacks more like
  # an ActiveRecord model.
  def self.order(column="name")
    column = column.to_s.downcase
    unless column.include?("name")
      raise "Bank.order can currently only order banks by name"
    end
    if column.include?("desc")
      all.sort_by(&:name).reverse
    else
      all.sort_by(&:name)
    end
  end

  def self.find_by(query)
    query.symbolize_keys!

    unless query.key?(:name)
      raise "Bank.find_by can currently only look up banks by name"
    end
    if id = TABLE.key(query[:name])
      find(id)
    else
      raise ActiveRecord::RecordNotFound, "Couldn't find #{self.class} with 'name'=#{query[:name]}"
    end
  end

  def initialize(id)
    unless @name = TABLE[id.to_i]
      raise ActiveRecord::RecordNotFound, "Couldn't find #{self.class} with 'id'=#{id}"
    end
    @id = id.to_i
  end

  def cards
    Card.where(bank_id: id)
  end

  def ==(other_bank)
    other_bank.is_a?(self.class) && other_bank.id == id
  end

  def <=>(other_bank)
    id <=> other_bank.id
  end

  # Hash equality. This lets us do things like Card.all.group_by(&:bank)
  # hash must return a fixnum that is always the same for identical Banks:
  def hash
    Digest::MD5.new.hexdigest("#{id}#{name}")[0..15].to_i(16)
  end
  def eql?(other_bank)
    self == other_bank && hash == other_bank.hash
  end

  def to_param
    name.downcase.parameterize.underscore
  end

  def inspect
     %[#<#{self.class} id: #{id}, name: "#{name}">]
  end

end

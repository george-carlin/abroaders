# Identity object. Since the list of Banks is small, will rarely change, and
# has very little information to store about each bank, a full-blown
# database-backed model is overkill. Instead the list of Banks is stored as a
# constant (TABLE) and Bank has a minimal set of methods to make it quack like
# an ActiveRecord model as far as Card is concerned (so we can get methods like
# Card#bank, Bank.find(id).cards, etc)
class Bank
  include Virtus.model

  attribute :id,   Fixnum
  attribute :name, String
  attribute :personal_phone, String
  attribute :business_phone, String

  # Note that only odd numbers are used for card IDs. This is because each card
  # has a deterministically-generated unique identifier which starts with a
  # number that represents the bank - but there are two numbers per bank, one
  # for personal cards are one for business cards. We're using odd numbers for
  # personal and even numbers for business - so e.g. a Chase personal card's
  # identifier will start with '01' while a Chase business card's identifier
  # will start with '02'
  TABLE = [
    # columns: id name, personal_phone, business_phone
    #
    # comments after each line contain additional data about the bank
    # that we're not doing anything with yet
    [1, "Chase", "888-245-0625", "800 453-9719"],
    [3, "Citibank", "(800) 695-5171", "800-763-9795"],
    [5, "Barclays", "866-408-4064", "866-408-4064"],
    # hours: 8am-5pm EST M-F
    [7, "American Express", "(877) 399-3083", "(877) 399-3083"],
    # when prompted, say “Application Status"
    [9, "Capital One", "(800) 625-7866", "(800) 625-7866"],
    # hours (M-F 8-8pm EST)
    [11, "Bank of America", "(877) 721-9405", "800-481-8277"],
    # when prompted, dial option 3 for “Application Status"
    [13, "US Bank", "800 685-7680", "800 685-7680" ],
    # hours: 8am-8pm EST (M-F)"
    [15, "Discover"],
    [17, "Diners Club"],
    [19, "SunTrust"],
    [21, "TD Bank"],
    [23, "Wells Fargo"],
  ]

  def self.find(id)
    find_by(id: id)
  end

  def self.all
    TABLE.map { |row| find(row[0]) }
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

    if query.key?(:id)
      if row = TABLE.find { |r| r[0] == query[:id] }
        id, name, pphone, bphone = *row
        new(id: id, name: name, personal_phone: pphone, business_phone: bphone)
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find #{self} with 'id'=#{query[:id]}"
      end
    elsif query.key?(:name)
      if row = TABLE.find { |r| r[1] == query[:name] }
        id, name, pphone, bphone = *row
        new(id: id, name: name, personal_phone: pphone, business_phone: bphone)
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find #{self} with 'name'=#{query[:name]}"
      end
    else
      raise "Bank.find_by can currently only look up banks by name or id"
    end
  end

  def self.find_by_name(name)
    find_by(name: name)
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

  def attributes
    # Virtus's 'attributes' method returns a hash with symbol keys, but
    # ActiveRecord::Base#attributes uses string keys. Keep things consistent:
    super.stringify_keys
  end

  def to_param
    name.downcase.parameterize.underscore
  end

  def inspect
     %[#<#{self.class} id: #{id}, name: "#{name}">]
  end

end

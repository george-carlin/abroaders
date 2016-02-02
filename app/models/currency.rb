# Leaving this as a PORO rather than an ActiveRecord model for now. Simple
# is beautiful.
#
# See the 'identity objects' section of this article:
# http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
class Currency

  attr_reader :id, :name, :short_name

  def self.all
    keys.map { |key| new(key) }
  end

  def self.keys
    table.keys.sort
  end


  def initialize(id)
    @id = id.to_s
    attributes  = self.class.table.fetch(@id)
    @name       = attributes.fetch("name")
    @short_name = attributes.fetch("short_name")
  end

  alias_method :to_s, :name

  def ==(other_currency)
    other_currency.is_a?(self.class) && id == other_currency.id
  end

  def inspect
    "#<Currency id: \"#{self.id}\", name: \"#{self.name}\", short_name: "\
    "\"#{self.short_name}\">"
  end

  private

  def self.table
    @table ||= JSON.parse(
      File.read(Rails.root.join("lib", "data", "currencies.json"))
    )
  end

end

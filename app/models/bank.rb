require 'dry-struct'

require 'types'

class Bank < Dry::Struct
  attribute :id, Types::Strict::Int
  attribute :business_phone, Types::Strict::String.optional
  attribute :name, Types::Strict::String
  attribute :personal_phone, Types::Strict::String.optional

  def card_products
    # Memoizing this caused failed tests; Bank.all is memoized from example to
    # example, and the individual banks within that array would contain
    # outdated memoized card products. Leave it unmemoized for now; YAGNI
    CardProduct.where(bank_id: id)
  end

  def self.all
    @all ||= begin
      __data__.map do |(id, name, p_phone, b_phone)|
        new(id: id.to_i, name: name, personal_phone: p_phone, business_phone: b_phone)
      end
    end
  end

  def self.find(id)
    all.detect { |b| b.id == id } || raise("unable to find Bank with ID `#{id}`")
  end

  def self.find_by_name!(name)
    all.detect { |b| b.name == name } || raise("unable to find Bank with name `#{name}`")
  end

  def self.alphabetical
    all.sort_by(&:name)
  end

  # @return [Array<Bank>]
  def self.with_at_least_one_product
    bank_ids = CardProduct.pluck(:bank_id).uniq
    all.select { |b| bank_ids.include?(b.id) }
  end

  def self.__data__
    @__data__ ||= CSV.parse(File.read(APP_ROOT.join('lib', 'data', 'banks.csv')))
  end
  private_class_method :__data__
end

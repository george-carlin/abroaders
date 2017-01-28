# A short string that allows the admin to quickly identify the card product.
# Format: AA-BBB-C.
# A: bank code - An integer (see below)
# B: product code - a 2-4 letter arbitrary code, set by the admin
# C: network code - if network is unknown, then '?'. Else 'A', 'M', or 'V', for
#                   Amex, MasterCard, or Visa respectively
#
class CardProduct < ApplicationRecord
  class Identifier
    attr_reader :identifier
    alias to_str identifier
    alias to_s   identifier

    def initialize(product)
      @product    = product
      @bank       = product.bank
      @identifier = [bank_code, product_code, network_code].join('-').freeze
    end

    def ==(other)
      identifier == other.to_str
    end

    def <=>(other)
      to_str <=> other.to_str
    end

    private

    # A 1-2 digit number which uniquely identifies both which bank the product belongs
    # to, and whether it is a business product or a personal one. this forms part of
    # the unique identifier for each product, which allows the admin to determine
    # these things about the product at a glance.
    #
    # The bank code is determined by the bank's id, which is always an odd number.
    # If this is a personal product, bank_number is equal to bank.id. If this is a
    # business product, bank_number is equal to bank.id + 1.
    #
    # (This numbering system is a legacy thing from before this app existed, when we
    # still doing everything through Fieldbook, Infusionsoft etc.)
    def bank_code
      '%.2d' % (@product.bp == "personal" ? @bank.personal_code : @bank.business_code)
    end

    def product_code
      @product.code
    end

    def network_code
      @product.network == "unknown_network" ? "?" : @product.network.upcase[0]
    end
  end
end

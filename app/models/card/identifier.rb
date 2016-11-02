# A short string that allows the admin to quickly identify the card.
# Format: AA-BBB-C.
# A: bank code - An integer (see below)
# B: card code - a 2-4 letter arbitrary code, set by the admin
# C: network code - if network is unknown, then '?'. Else 'A', 'M', or 'V', for
#                   Amex, MasterCard, or Visa respectively
#
class Card::Identifier
  attr_reader :identifier
  alias to_str identifier
  alias to_s   identifier

  def initialize(card)
    @card = card
    @bank = card.bank
    @identifier = [bank_code, card_code, network_code].join('-').freeze
  end

  def ==(other)
    identifier == other.to_str
  end

  def <=>(other)
    to_str <=> other.to_str
  end

  private

  # A 1-2 digit number which uniquely identifies both which bank the card belongs
  # to, and whether it is a business card or a personal one. this forms part of
  # the unique identifier for each card, which allows the admin to determine
  # these things about the card at a glance.
  #
  # The bank code is determined by the bank's id, which is always an odd number.
  # If this is a personal card, bank_number is equal to bank.id. If this is a
  # business card, bank_number is equal to bank.id + 1.
  #
  # (This numbering system is a legacy thing from before this app existed, when we
  # still doing everything through Fieldbook, Infusionsoft etc.)
  def bank_code
    '%.2d' % (@card.bp == "personal" ? @bank.personal_code : @bank.business_code)
  end

  def card_code
    @card.code
  end

  def network_code
    @card.network == "unknown_network" ? "?" : @card.network.upcase[0]
  end
end

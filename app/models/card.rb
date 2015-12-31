class Card < ApplicationRecord
   self.inheritance_column = :_no_sti

  # Attributes

  enum bp: [:business, :personal]
  enum brand: [:visa, :mastercard, :amex]
  enum type: [:credit, :charge, :debit]

  def full_name
    # Call them all 'Chase' cards until we've added Banks
    "#{identifier} - Chase - #{name}"
  end

  # Validations
  
  validates :identifier, presence: true, uniqueness: true
  validates :name, presence: true
  validates :brand, presence: true
  validates :bp, presence: true
  validates :type, presence: true
  validates :annual_fee_cents, presence: true

  # Associations

  # has_many :offers,   class_name: "CardOffer"
  # has_many :accounts, class_name: "CardAccount"

end

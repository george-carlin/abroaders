class Bank < ApplicationRecord
  has_many :cards

  # 'person_code' column = Abroaders' internal identifier for the bank. For legacy
  # reasons we have two codes per bank, one for personal banking and the other
  # for business. personal_code is stored in the DB (and should always be
  # an odd number) - business_code is just personal_code + 1.
  #
  # e.g. a Chase personal card's identifier
  # will start with '01' while a Chase business card's identifier will start
  # with '02'.

  def business_code
    personal_code + 1
  end
end

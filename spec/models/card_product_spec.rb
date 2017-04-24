require 'rails_helper'

RSpec.describe CardProduct do
  example '.recommendable' do
    # product with no offers:
    create(:product)

    product_with_no_live_offers = create(:product)
    kill_offer(create_offer(product: product_with_no_live_offers))

    product_with_live_offers = create(:product)
    create_offer(product: product_with_live_offers)
    create_offer(product: product_with_live_offers)

    expect(described_class.recommendable).to eq [product_with_live_offers]
  end

  example 'annual_fee=' do
    card_product = described_class.new
    card_product.annual_fee = 123.45
    expect(card_product.annual_fee_cents).to eq 123_45

    # rounding up/down:
    card_product.annual_fee = 123.459
    expect(card_product.annual_fee_cents).to eq 123_46

    card_product.annual_fee = 123.454
    expect(card_product.annual_fee_cents).to eq 123_45

    # #annual_fee= uses the #round method; bear in mind that the behaviour of
    # this method changes in Ruby 2.4:
    #
    # # Ruby 2.3
    # 2.5.round # => 3
    # # Ruby 2.4
    # 2.5.round # => # 2
  end

  example '#bank' do
    product = described_class.new(bank_id: 5)
    expect(product.bank).to eq Bank.find(5)

    # make sure that setting bank_id overrides any memoized value of #bank:
    product.bank_id = 7
    expect(product.bank).to eq Bank.find(7)
  end

  example '#bank_id=' do
    bank = Bank.new(id: 11, name: 'Fake bank', business_phone: nil, personal_phone: nil)
    product = described_class.new
    product.bank = bank
    expect(product.bank_id).to eq 11
    expect(product.bank.name).to eq 'Fake bank'
  end

  example '#reload' do
    # unset memoized @bank:
    card_product = create(
      :product,
      name: 'Saved name',
      annual_fee_cents: 123,
      bank: Bank.all[0],
    )

    card_product.name = 'Unsaved name'

    # create another instance of the same saved record and update it so
    # that the DB gets updated but the ivar in the first product instance
    # doesn't change:
    copy = CardProduct.find(card_product.id)
    # update annual_fee_cents too to check that the regular behaviour of
    # #reload is still working too:
    copy.update!(bank: Bank.all[1], annual_fee_cents: 456)

    card_product.reload
    # bank and annual fee should have changed but name shouldn't:
    expect(card_product.name).to eq 'Saved name'
    expect(card_product.annual_fee_cents).to eq 456
    expect(card_product.bank).to eq Bank.all[1]
  end
end

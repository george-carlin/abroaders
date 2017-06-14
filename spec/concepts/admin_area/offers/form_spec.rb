require 'rails_helper'

RSpec.describe AdminArea::Offers::Form do
  let(:card_product) { create(:card_product) }

  # TODO we have some offers in the DB where points_awarded is 0, some are
  # live, and they're a mixture of all three original condition types.
  # Shouldn't points_awarded be >0, not >=0, for *all* on_minimum_spend
  # offers? Talk to Erik about this.

  # You must create a new form object every time; Reform doesn't support
  # calling 'validate' multiple times on the same form instance.
  def validate_attrs(attrs)
    form = described_class.new(offer)
    valid = form.validate(attrs)
    [form, valid]
  end

  def validates_int(key)
    valid_attrs[key] = nil
    expect(validate_attrs(valid_attrs)[1]).to be false
    valid_attrs[key] = POSTGRESQL_MAX_INT_VALUE
    expect(validate_attrs(valid_attrs)[1]).to be true
    valid_attrs[key] += 1
    expect(validate_attrs(valid_attrs)[1]).to be false

    # works with string values too (i.e. from HTTP params):
    valid_attrs[key] = '-1'
    expect(validate_attrs(valid_attrs)[1]).to be false
    valid_attrs[key] = '0'
    expect(validate_attrs(valid_attrs)[1]).to be true
    valid_attrs[key] = POSTGRESQL_MAX_INT_VALUE.to_s
    expect(validate_attrs(valid_attrs)[1]).to be true
    valid_attrs[key] = (POSTGRESQL_MAX_INT_VALUE + 1).to_s
    expect(validate_attrs(valid_attrs)[1]).to be false
  end

  def validates_str(key)
    valid_attrs[key] = nil
    expect(validate_attrs(valid_attrs)[1]).to be false

    valid_attrs[key] = ''
    expect(validate_attrs(valid_attrs)[1]).to be false

    valid_attrs[key] = ' '
    expect(validate_attrs(valid_attrs)[1]).to be false
  end

  # Don't need to validate that 'partner' key is required because
  # it has a default value.
  #
  # Don't need to validate that 'partner' value is valid for the enum because
  # it's impossible to submit an invalid option through the form, and the Form
  # obj will raise an error if you do submit one
  #
  # ^ both these points also apply to 'condition'

  describe '"on minimum spend" offer' do
    let(:offer) { Offer.new(condition: 'on_minimum_spend') }

    let(:valid_attrs) do
      {
        cost: 0,
        days: 90,
        link: 'http://example.com',
        partner: 'none',
        points_awarded: 10_000,
        spend: 1000,
      }
    end

    example 'valid attributes' do
      _, valid = validate_attrs(valid_attrs)
      expect(valid).to be true
    end

    specify 'link must be present and stripped' do
      validates_str(:link)
    end

    specify 'cost must be present, >= 0, and <= MAX_INT' do
      validates_int(:cost)
    end

    specify 'spend must be present, >= 0, and <= MAX_INT' do
      validates_int(:spend)
    end

    specify 'points_awarded must be present, >= 0, and <= MAX_INT' do
      validates_int(:points_awarded)
    end

    specify 'days must be present, >= 0, and <= MAX_INT' do
      validates_int(:days)
    end

    example 'saving offer' do
      offer.card_product = card_product
      form = described_class.new(offer)
      expect(form.validate(valid_attrs)).to be true
      expect { form.save }.to change { Offer.count }.by(1)

      offer.reload
      expect(offer.cost).to eq 0
      expect(offer.days).to eq 90
      expect(offer.link).to eq 'http://example.com'
      expect(offer.partner).to eq 'none'
      expect(offer.points_awarded).to eq 10_000
      expect(offer.spend).to eq 1000
    end
  end

  describe '"on approval" offer' do
    let(:offer) { Offer.new(condition: 'on_approval') }

    let(:valid_attrs) do
      {
        cost: 0,
        link: 'http://example.com',
        partner: 'none',
        points_awarded: 0,
      }
    end

    example 'valid attributes' do
      _, valid = validate_attrs(valid_attrs)
      expect(valid).to be true
    end

    specify 'link must be present and stripped' do
      validates_str(:link)
    end

    specify 'cost must be present, >= 0, and <= MAX_INT' do
      validates_int(:cost)
    end

    specify 'points_awarded must be present, >= 0, and <= MAX_INT' do
      validates_int(:points_awarded)
    end

    example 'saving offer' do
      offer.card_product = card_product
      form = described_class.new(offer)
      expect(form.validate(valid_attrs)).to be true
      expect { form.save }.to change { Offer.count }.by(1)

      offer.reload
      expect(offer.cost).to eq 0
      expect(offer.days).to be_nil
      expect(offer.link).to eq 'http://example.com'
      expect(offer.partner).to eq 'none'
      expect(offer.points_awarded).to eq 0
      expect(offer.spend).to be_nil
    end
  end

  describe '"on first purchase" offer' do
    let(:offer) { Offer.new(condition: 'on_first_purchase') }

    let(:valid_attrs) do
      {
        cost: 0,
        days: 90,
        link: 'http://example.com',
        partner: 'none',
        points_awarded: 50_000,
      }
    end

    example 'valid attributes' do
      _, valid = validate_attrs(valid_attrs)
      expect(valid).to be true
    end

    specify 'link must be present and stripped' do
      validates_str(:link)
    end

    specify 'cost must be present, >= 0, and <= MAX_INT' do
      validates_int(:cost)
    end

    specify 'points_awarded must be present, >= 0, and <= MAX_INT' do
      validates_int(:points_awarded)
    end

    specify 'days must be present, >= 0, and <= MAX_INT' do
      validates_int(:days)
    end

    example 'saving offer' do
      offer.card_product = card_product
      form = described_class.new(offer)
      expect(form.validate(valid_attrs)).to be true
      expect { form.save }.to change { Offer.count }.by(1)

      offer.reload
      expect(offer.cost).to eq 0
      expect(offer.days).to eq 90
      expect(offer.link).to eq 'http://example.com'
      expect(offer.partner).to eq 'none'
      expect(offer.points_awarded).to eq 50_000
      expect(offer.spend).to be_nil
    end
  end
end

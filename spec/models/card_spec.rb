require 'rails_helper'

RSpec.describe Card do
  let(:account) { Account.new }
  let(:person)  { account.build_owner }
  let(:product) { build(:card_product) }
  let(:offer)   { Offer.new(card_product: product) }
  let(:card) { described_class.new(person: person) }

  before { card.offer = offer }

  example "#recommended?" do
    expect(card.recommended?).to be false
    card.recommended_at = Time.current
    expect(card.recommended?).to be true
  end

  example "#declined?" do
    card.recommended_at = Time.current
    expect(card.declined?).to be false
    card.declined_at = Time.current
    expect(card.declined?).to be true
  end

  example "#denied?" do
    card.recommended_at = Time.current
    card.applied_on = Time.current
    expect(card.denied?).to be false
    card.denied_at = Time.current
    expect(card.denied?).to be true
  end

  example '#offer?' do
    card.offer = offer
    expect(card.offer?).to be true
    card.offer = nil
    expect(card.offer?).to be false
  end

  # Callbacks

  example "set #card_product to #offer.card_product before save" do
    offer   = create_offer
    product = offer.card_product
    card = Card.new(card_product: nil, offer: offer, person: create_account.owner)
    card.save!
    expect(card.card_product_id).to eq product.id
  end

  # Scopes

  describe '.recommended' do
    let(:product) { create(:card_product) }
    let(:offer) { create_offer(card_product: product) }
    let(:person) { create_account.owner }

    # extend the macro so that we always use the same offer and person,
    # just to avoid making a bunch of unnecessary DB writes
    def create_rec(*args)
      overrides = args.last.is_a?(Hash) ? args.pop : {}
      traits    = args
      overrides[:offer]  = offer
      overrides[:person] = person

      super(*traits, overrides)
    end

    example '' do
      create_card_account
      returned = create_card_recommendation
      expect(described_class.recommended).to eq [returned]
    end

    example ".actionable" do
      # not actionable:
      create_rec(:approved)
      create_rec(:nudged, :denied)
      create_rec(:redenied)
      create_rec(:expired)
      create_card_account(card_product: product, person: person)
      decline_rec(create_rec)

      # open after reconsideration:
      create_rec(:denied, :called, :approved)
      # open after nudging:
      create_rec(:applied, :nudged, :approved)

      actionable = [
        # brand new:
        create_rec,
        # applied but pending:
        create_rec(:applied),
        # applied and nudged:
        create_rec(:applied, :nudged),
        # denied but reconsiderable:
        create_rec(:denied),
        # denied, called, pending:
        create_rec(:denied, :called),
      ]

      expect(Card.recommended.actionable).to match_array(actionable)
    end

    example ".unresolved" do
      # resolved:
      create_rec(:applied)
      create_rec(:expired)
      decline_rec(create_rec)

      # not a recommendation:
      create_card_account(card_product: product, person: person)

      unresolved = create_rec

      expect(Card.recommended.unresolved).to eq [unresolved]
    end
  end # .recommended

  example '#actionable?' do
    time = Time.now
    rec = Card.new(recommended_at: time)
    expect(rec.actionable?).to be true
    rec.expired_at = time
    expect(rec.actionable?).to be false
    rec.expired_at = nil
    rec.declined_at = time
    expect(rec.actionable?).to be false
    rec.declined_at = nil
    rec.applied_on = time
    expect(rec.actionable?).to be true
    rec.denied_at = time
    expect(rec.actionable?).to be true
    rec.redenied_at = time
    expect(rec.actionable?).to be false
    rec.redenied_at = nil
    rec.nudged_at = time
    expect(rec.actionable?).to be false
    rec.denied_at = nil
    expect(rec.actionable?).to be true
    rec.called_at = time
    expect(rec.actionable?).to be true
    rec.denied_at = time
    expect(rec.actionable?).to be false
    rec.denied_at = nil
    allow(rec).to receive(:unopened?).and_return(false)
    expect(rec.actionable?).to be false
  end

  describe '#status' do
    let(:date) { Time.zone.today }

    # possible values: [recommended, declined, applied, denied, expired]
    let(:attrs) { { recommended_at: date } }

    subject { Card.new(attrs).status }

    it { is_expected.to eq 'recommended' }

    context 'when opened_on is present' do
      before { attrs[:opened_on] = date }
      it { is_expected.to eq 'opened' }
    end

    context 'when expired_at is present' do
      before { attrs[:expired_at] = date }
      it { is_expected.to eq 'expired' }
    end

    context 'when applied_on is present' do
      before { attrs[:applied_on] = date }

      context 'and denied_at is present' do
        before { attrs[:denied_at] = date }
        it { is_expected.to eq 'denied' }
      end

      context 'and denied_at is nil' do
        it { is_expected.to eq 'applied' }
      end
    end

    context 'when declined_at is present' do
      before { attrs[:declined_at] = date }
      it { is_expected.to eq 'declined' }
    end
  end
end

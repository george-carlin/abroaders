require 'rails_helper'

RSpec.describe AdminArea::CardRecommendations::Update do
  include ZapierWebhooksMacros

  let(:op) { described_class }

  let(:person)  { create_account(:onboarded).owner }
  let(:product) { create(:card_product) }

  let(:dec_2015) { Date.new(2015, 12) }
  let(:jan_2016) { Date.new(2016, 1) }

  let(:params) { { card: {} } }

  # Use the same person and product every time for DRYness.
  def create_rec(options = {})
    super(options.merge(person: person, card_product: product))
  end

  example 'updating' do
    rec = create_rec
    params[:card] = {
      applied_on: dec_2015,
      declined_at: jan_2016,
      decline_reason: 'whatever',
    }
    params[:id] = rec.id

    expect_not_to_queue_card_opened_webhook
    result = op.(params)
    expect(result.success?).to be true

    rec = result['model']
    expect(rec.applied_on).to eq dec_2015
    expect(rec.declined_at.to_date).to eq jan_2016
    expect(rec.decline_reason).to eq 'whatever'
  end

  example 'updating to opened' do
    rec = create_rec
    params[:card] = { opened_on: dec_2015 }
    params[:id] = rec.id

    expect_to_queue_card_opened_webhook_with_id(rec.id)

    result = op.(params)
    expect(result.success?).to be true

    expect(result['model'].opened_on).to eq dec_2015
  end

  example 'updating when already opened' do
    rec = create_rec(opened_on: Date.today)
    params[:card] = { applied_on: dec_2015, denied_at: jan_2016 }
    params[:id] = rec.id

    expect_not_to_queue_card_opened_webhook

    result = op.(params)
    expect(result.success?).to be true

    rec = result['model']
    expect(rec.applied_on).to eq dec_2015
    expect(rec.denied_at.to_date).to eq jan_2016
  end

  example 'invalid save' do
    rec = create_rec
    # missing decline reason:
    params[:card] = { applied_on: dec_2015, declined_at: jan_2016 }
    params[:id] = rec.id

    expect_not_to_queue_card_opened_webhook

    rec.reload
    expect do
      result = op.(params)
      expect(result.success?).to be false
      rec.reload
    end.not_to change { rec.updated_at }
  end
end

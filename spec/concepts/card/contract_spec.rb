require 'rails_helper'

describe Card::Contract do
  let(:card) { Card.new }

  def validate(attrs)
    form = described_class.new(card)
    form.validate(attrs)
  end

  def errors_for(attrs)
    form = described_class.new(card)
    form.validate(attrs)
    form.errors
  end

  let(:yesterday) { Date.yesterday }
  let(:tomorrow)  { Date.tomorrow }
  let(:today)     { Date.today }

  # remember that if the card is not a recommendation, we massage the
  # 'opened_at' and 'closed_at' dates to be at the END OF the given months. But
  # this will happen AFTER the validation stage.

  # Lines like this don't work, presumably because shoulda-matchers doesn't
  # play nicely with Reform:
  # it { is_expected.to validate_presence_of(:opened_at) }

  specify 'opened_at must be present' do
    expect(errors_for(opened_at: nil)[:opened_at]).to include "can't be blank"
  end

  specify 'opened_at must be in the past' do
    msg = t('errors.not_in_the_future?')
    expect(errors_for(opened_at: tomorrow)[:opened_at]).to include msg
    expect(errors_for(opened_at: today)[:opened_at]).not_to include msg
  end

  describe 'closed_at' do
    it 'must be present iff "closed" is true' do
      attrs = { opened_at: yesterday, closed: false }
      expect(errors_for(attrs)[:closed_at]).to be_empty
      attrs[:closed] = true
      expect(errors_for(attrs)[:closed_at]).to include "can't be blank"
      attrs[:closed_at] = today
      expect(errors_for(attrs)[:closed_at]).to be_empty
    end

    it 'is >= opened_at and not in the past' do
      msg = t('errors.not_in_the_future?')
      attrs = { opened_at: today, closed: true, closed_at: tomorrow }
      expect(errors_for(attrs)[:closed_at]).to include msg
      attrs[:closed_at] = yesterday
      expect(errors_for(attrs)[:closed_at]).to include 'must be later than opened date'
      attrs[:closed_at] = today
      expect(errors_for(attrs)[:closed_at]).to be_empty
      # HTML form will pass in closed_at even when closed is unchecked, so
      # handle this case:
      attrs[:closed]    = false
      attrs[:closed_at] = yesterday
      expect(errors_for(attrs)[:closed_at]).to be_empty
    end
  end
end

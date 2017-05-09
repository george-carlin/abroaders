require 'rails_helper'

RSpec.describe CardAccount::Form do
  let(:card_account) { Card.new }

  def validate(attrs)
    form = described_class.new(card_account)
    form.validate(attrs)
  end

  def errors_for(attrs)
    form = described_class.new(card_account)
    form.validate(attrs)
    form.errors
  end

  let(:yesterday) { Date.today - 2 }
  let(:tomorrow)  { Date.today + 2 }
  let(:today)     { Date.today }

  # remember that if the card is not a recommendation, we massage the
  # 'opened_on' and 'closed_on' dates to be at the END OF the given months. But
  # this will happen AFTER the validation stage.

  # Lines like this don't work, presumably because shoulda-matchers doesn't
  # play nicely with Reform:
  # it { is_expected.to validate_presence_of(:opened_on) }

  specify 'opened_on must be present' do
    expect(errors_for(opened_on: nil)[:opened_on]).to include "can't be blank"
  end

  specify 'opened_on must be in the past' do
    msg = t('errors.not_in_the_future?')
    expect(errors_for(opened_on: tomorrow)[:opened_on]).to include msg
    expect(errors_for(opened_on: today)[:opened_on]).not_to include msg
  end

  describe 'closed_on' do
    it 'must be present iff "closed" is true' do
      attrs = { opened_on: yesterday, closed: false }
      expect(errors_for(attrs)[:closed_on]).to be_empty
      attrs[:closed] = true
      expect(errors_for(attrs)[:closed_on]).to include "can't be blank"
      attrs[:closed_on] = today
      expect(errors_for(attrs)[:closed_on]).to be_empty
    end

    it 'is >= opened_on and not in the past' do
      msg = t('errors.not_in_the_future?')
      attrs = { opened_on: today, closed: true, closed_on: tomorrow }
      expect(errors_for(attrs)[:closed_on]).to include msg
      attrs[:closed_on] = yesterday
      expect(errors_for(attrs)[:closed_on]).to include 'must be later than opened date'
      attrs[:closed_on] = today
      expect(errors_for(attrs)[:closed_on]).to be_empty
      # HTML form will pass in closed_on even when closed is unchecked, so
      # handle this case:
      attrs[:closed]    = false
      attrs[:closed_on] = yesterday
      expect(errors_for(attrs)[:closed_on]).to be_empty
    end
  end
end

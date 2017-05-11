require 'cells_helper'

RSpec.describe LoyaltyAccount::Cell::ExpirationDate do
  let(:account) { Struct.new(:expiration_date).new(expires) }
  let(:result) { cell(account).() }

  def have_text(text)
    have_selector '.loyalty_account_expiration_date', text: text
  end

  def have_warning_icon
    have_selector '.fa.fa-warning'
  end

  context 'expires in future' do
    let(:expires) { 6.months.from_now }
    it '' do
      expect(result).to have_text 'In 6 months'
      expect(result).not_to have_warning_icon
    end
  end

  context 'expires tomorrow' do
    let(:expires) { 2.days.from_now - 5.seconds }
    it '' do
      expect(result).to have_text 'Tomorrow'
      expect(result).not_to have_warning_icon
    end
  end

  context 'expires today' do
    let(:expires) { Date.today }
    it '' do
      expect(result).to have_text 'Today'
      expect(result).to have_warning_icon
    end
  end

  context 'expired yesterday' do
    let(:expires) { 2.days.ago + 5.seconds }
    it '' do
      expect(result).to have_text 'Yesterday'
      expect(result).to have_warning_icon
    end
  end

  context 'expired in past' do
    let(:expires) { 6.months.ago }
    it '' do
      expect(result).to have_text '6 months ago'
      expect(result).to have_warning_icon
    end
  end

  context 'unknown' do
    let(:expires) { nil }
    it '' do
      expect(result).to have_text 'Unknown'
      expect(result).to have_warning_icon
    end
  end
end

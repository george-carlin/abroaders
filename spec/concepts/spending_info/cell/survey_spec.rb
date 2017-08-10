require 'cells_helper'

RSpec.describe SpendingInfo::Cell::Survey do
  let(:account) { raise 'define :account in sub-blocks' }
  let(:owner) { account.owner }

  def have_subheader(text)
    have_selector 'h3', text: text
  end

  describe '::SoloSurvey' do
    let(:account) { create_account(:eligible) }

    it 'addresses me as "You"' do
      form = SpendingSurvey.new(account: account)
      rendered = cell(account, form: form).()
      expect(rendered).to have_subheader 'What is your credit score?'
      expect(rendered).to have_subheader 'How much do you spend per month?'
      expect(rendered).to have_subheader 'Do you have a business?'
      expect(rendered).to have_subheader(
        'Do you plan to apply for a loan of over $5,000 in the next 12 months?',
      )

      expect(rendered).to have_content(
        'What is your average monthly personal spending that could be '\
        'charged to a credit card account?',
      )
    end
  end

  describe '::CouplesSurvey' do
    let(:account) { create_account(:couples, :eligible) }

    it 'addresses us by name' do
      form = SpendingSurvey.new(account: account)
      rendered = cell(account, form: form).()
      expect(rendered).to have_subheader 'What is Erik\'s credit score?'
      expect(rendered).to have_subheader 'What is Gabi\'s credit score?'
      expect(rendered).to have_subheader 'How much do you spend per month?'
      expect(rendered).to have_subheader 'Does Erik have a business?'
      expect(rendered).to have_subheader 'Does Gabi have a business?'
      expect(rendered).to have_subheader(
        'Does Erik plan to apply for a loan of over $5,000 in the next 12 months?',
      )
      expect(rendered).to have_subheader(
        'Does Gabi plan to apply for a loan of over $5,000 in the next 12 months?',
      )

      expect(rendered).to have_content(
        'Please estimate the combined monthly spending for Erik and Gabi that '\
        'could be charged to a credit card account.',
      )
    end
  end
end

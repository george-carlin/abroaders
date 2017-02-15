require 'cells_helper'

RSpec.describe SpendingInfo::Cell::Survey do
  controller SpendingInfosController

  let(:account) { Account.new }
  let(:owner)   { account.build_owner(first_name: 'Erik', eligible: true) }

  def have_subheader(text)
    have_selector 'h3', text: text
  end

  describe '::SoloSurvey' do
    it 'addresses me as "You"' do
      result = {
        'account' => account,
        'contract.default' => SpendingSurvey.new(account: account),
        'eligible_people' => [owner],
      }
      rendered = show(result)
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
    let!(:companion) { account.build_companion(first_name: 'Gabi', eligible: true) }

    it 'addresses us by name' do
      result = {
        'account' => account,
        'contract.default' => SpendingSurvey.new(account: account),
        'eligible_people'  => [owner, companion],
      }
      rendered = show(result)
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

require 'rails_helper'

# TODO email subject?
# TODO exclude cards where annual fee is 0. (Are there are any other cases I
# should be excluding?)

RSpec.describe CardAccount::SendAnnualFeeReminder do
  let(:op) { described_class }

  before do
    Timecop.freeze(Date.new(2017, 5, 1))
    @old_env = ENV['ANNUAL_FEE_REMINDER_TEST_MODE']
    ENV['ANNUAL_FEE_REMINDER_TEST_MODE'] = 'true'
  end

  after do
    ENV['ANNUAL_FEE_REMINDER_TEST_MODE'] = @old_env
    Timecop.return
  end

  def create_couples_account
    create_account(:couples, :eligible, :onboarded)
  end

  def create_solo_account
    create_account(:eligible, :onboarded)
  end

  # DRY specs are happy specs
  def create_card_account(person, attrs = {})
    super(attrs.merge(person: person))
  end

  def has_no_cards_text(name)
    "#{name} has no cards with an annual fee due this month"
  end

  RSpec::Matchers.define :have_card do |card|
    include ActionView::Helpers::NumberHelper

    match do |email|
      body = email.body.to_s
      body.include?("id=\"card_#{card.id}\"")
      body.include?(product_name(card)) && body.include?(annual_fee(card))
    end

    match_when_negated do |email|
      body = email.body.to_s
      !body.include?("id=\"card_#{card.id}\"")
      # Don't test that the card product name and annual fee are not present,
      # because another card account might use the same product
    end

    def annual_fee(card)
      number_to_currency(card.card_product.annual_fee)
    end

    def product_name(card)
      CardProduct::Cell::FullName.(card.card_product, with_bank: true).()
    end
  end

  # Stick with a couple of simple dates for now. The more fine-grained testing
  # that specific 'opened_on' dates do/don't trigger the reminder is is the
  # specs for CardAccount::Query::AnnualFeeDue.
  let(:last_month) { Date.new(2015, 4, 30) }
  let(:next_month) { Date.new(2015, 6, 1) }
  let(:this_month) { Date.new(2015, 5, 15) }

  example 'account with no cards' do
    create_solo_account
    expect { op.() }.not_to send_email
  end

  example 'account with no card accounts due for reminder' do
    account = create_solo_account
    person = account.owner
    create_card_account(person, opened_on: next_month)
    create_card_account(person, opened_on: this_month, closed_on: this_month)
    create_card_account(person, opened_on: last_month)

    expect { op.() }.not_to send_email
  end

  example 'solo account with one card due' do
    account = create_solo_account
    person = account.owner

    not_due = [
      create_card_account(person, opened_on: next_month),
      create_card_account(person, opened_on: this_month, closed_on: this_month),
      create_card_account(person, opened_on: last_month),
    ]
    due = create_card_account(person, opened_on: this_month)

    expect { op.() }.to send_email.to(account.email)

    email = ApplicationMailer.deliveries.last.html_part

    expect(email).to have_card(due)
    not_due.each { |card| expect(email).not_to have_card(card) }

    body = email.body.to_s
    expect(body).to include "Hey #{person.first_name},"
    expect(body).to include 'a card'
    expect(body).not_to include "#{person.first_name}'s cards"
  end

  example 'solo accounts with multiple cards due' do
    account = create_solo_account
    person = account.owner

    not_due = [
      create_card_account(person, opened_on: next_month),
      create_card_account(person, opened_on: this_month, closed_on: this_month),
      create_card_account(person, opened_on: last_month),
    ]
    due_0 = create_card_account(person, opened_on: this_month)
    due_1 = create_card_account(person, opened_on: this_month)

    expect { op.() }.to send_email.to(account.email)

    email = ApplicationMailer.deliveries.last.html_part
    expect(email).to have_card(due_0)
    expect(email).to have_card(due_1)
    not_due.each { |card| expect(email).not_to have_card(card) }

    body = email.body.to_s
    name = person.first_name
    expect(body).to include "Hey #{name},"
    expect(body).to include '2 cards'
    expect(body).not_to include "#{name}'s cards"
    expect(body).not_to include has_no_cards_text(name)
  end

  example 'couples account with 1 card due for owner' do
    account = create_account(:couples, :eligible, :onboarded)
    owner, companion = account.people.sort_by(&:type).reverse

    not_due = [
      create_card_account(owner, opened_on: next_month),
      create_card_account(companion, opened_on: this_month, closed_on: this_month),
      create_card_account(owner, opened_on: last_month),
    ]
    due = create_card_account(owner, opened_on: this_month)

    expect { op.() }.to send_email.to(account.email)

    email = ApplicationMailer.deliveries.last.html_part
    expect(email).to have_card(due)
    not_due.each { |card| expect(email).not_to have_card(card) }

    expect(email.body).to include "Hey #{owner.first_name},"
    expect(email.body).to include 'a card'

    expect(email).to have_card(due)
    not_due.each { |card| expect(email).not_to have_card(card) }

    body = email.body.to_s
    expect(body).to include "#{owner.first_name}'s cards"
    expect(body).not_to include "#{companion.first_name}'s cards"
    expect(body).not_to include has_no_cards_text(owner.first_name)
    expect(body).to include has_no_cards_text(companion.first_name)
  end

  example 'couples account with 1 card due for companion' do
    account = create_account(:couples, :eligible, :onboarded)
    owner, companion = account.people.sort_by(&:type).reverse

    due = create_card_account(companion, opened_on: this_month)
    not_due = [
      create_card_account(owner, opened_on: next_month),
      create_card_account(companion, opened_on: this_month, closed_on: this_month),
      create_card_account(owner, opened_on: last_month),
    ]

    expect { op.() }.to send_email.to(account.email)

    email = ApplicationMailer.deliveries.last.html_part

    expect(email).to have_card(due)
    not_due.each { |card| expect(email).not_to have_card(card) }

    body = email.body.to_s
    expect(body).to include "Hey #{owner.first_name},"
    expect(body).to include 'a card'
    expect(body).not_to include "#{owner.first_name}'s cards"
    expect(body).to include "#{companion.first_name}'s cards"
    expect(body).to include has_no_cards_text(owner.first_name)
    expect(body).not_to include has_no_cards_text(companion.first_name)
  end

  example 'couples account with multiple cards due for one person' do
    account = create_account(:couples, :eligible, :onboarded)
    owner, companion = account.people.sort_by(&:type).reverse

    due_0 = create_card_account(owner, opened_on: this_month)
    due_1 = create_card_account(owner, opened_on: this_month)
    not_due = [
      create_card_account(owner, opened_on: next_month),
      create_card_account(companion, opened_on: this_month, closed_on: this_month),
      create_card_account(owner, opened_on: last_month),
    ]

    expect { op.() }.to send_email.to(account.email)
    email = ApplicationMailer.deliveries.last.html_part

    expect(email).to have_card(due_0)
    expect(email).to have_card(due_1)
    not_due.each { |card| expect(email).not_to have_card(card) }

    body = email.body.to_s
    expect(body).to include "Hey #{owner.first_name},"
    expect(body).to include '2 cards'
    expect(body).not_to include "#{companion.first_name}'s cards"
    expect(body).to include "#{owner.first_name}'s cards"
    expect(body).not_to include has_no_cards_text(owner.first_name)
    expect(body).to include has_no_cards_text(companion.first_name)
  end

  example 'couples account with cards for both owner and companion' do
    account = create_account(:couples, :eligible, :onboarded)
    owner, companion = account.people.sort_by(&:type).reverse

    due_0 = create_card_account(owner, opened_on: this_month)
    due_1 = create_card_account(owner, opened_on: this_month)
    due_2 = create_card_account(companion, opened_on: this_month)
    not_due = [
      create_card_account(owner, opened_on: next_month),
      create_card_account(companion, opened_on: this_month, closed_on: this_month),
      create_card_account(owner, opened_on: last_month),
    ]

    expect { op.() }.to send_email.to(account.email)
    email = ApplicationMailer.deliveries.last.html_part

    expect(email).to have_card(due_0)
    expect(email).to have_card(due_1)
    expect(email).to have_card(due_2)
    not_due.each { |card| expect(email).not_to have_card(card) }

    body = email.body.to_s
    expect(body).to include "Hey #{owner.first_name},"
    expect(body).to include '3 cards'
    expect(body).to include "#{companion.first_name}'s cards"
    expect(body).to include "#{owner.first_name}'s cards"
    expect(body).not_to include has_no_cards_text(owner.first_name)
    expect(body).not_to include has_no_cards_text(companion)
  end
end

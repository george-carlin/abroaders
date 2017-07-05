require 'rails_helper'

RSpec.describe CardAccount::SendAnnualFeeReminder do
  let(:op) { described_class }

  before do
    Timecop.freeze(Date.new(2017, 5, 1))
    @old_env = ENV['ANNUAL_FEE_REMINDER_TEST_MODE']
    ENV['ANNUAL_FEE_REMINDER_TEST_MODE' ] = 'true'
  end

  after do
    ENV['ANNUAL_FEE_REMINDER_TEST_MODE' ] = @old_env
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

  # Stick with a couple of simple dates for now. The more fine-grained testing
  # that specific 'opened_on' dates do/don't trigger the reminder is is the
  # specs for CardAccount::Query::AnnualFeeDue.
  let(:last_month) { Date.new(2015, 4, 30) }
  let(:next_month) { Date.new(2015, 6, 1) }
  let(:this_month) { Date.new(2015, 5, 15) }

  example 'account with no card accounts' do
    _account = create_solo_account
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

    # cards that aren't due:
    create_card_account(person, opened_on: next_month)
    create_card_account(person, opened_on: this_month, closed_on: this_month)
    create_card_account(person, opened_on: last_month)

    due = create_card_account(person, opened_on: this_month)

    expect { op.() }.to send_email.to(account.email)

    # TODO test message body: should say 'Hey (name),', say 'a card' instead
    # of '1 card', and mention the correct card with the correct annual fee
  end

  example 'solo accounts with multiple cards due' do
    account = create_solo_account
    person = account.owner

    # cards that aren't due:
    create_card_account(person, opened_on: next_month)
    create_card_account(person, opened_on: this_month, closed_on: this_month)
    create_card_account(person, opened_on: last_month)

    due_0 = create_card_account(person, opened_on: this_month)
    due_1 = create_card_account(person, opened_on: this_month)

    expect { op.() }.to send_email.to(account.email)

    # TODO test message body: should say 'Hey (name),', say '2 cards' instead
    #  and mention the correct cards with the correct annual fees
  end

  example 'couples account with 1 card due for owner' do
    account = create_account(:couples, :eligible, :onboarded)
    owner, comp = account.people.sort_by(&:type).reverse

    # cards that aren't due:
    create_card_account(owner, opened_on: next_month)
    create_card_account(comp, opened_on: this_month, closed_on: this_month)
    create_card_account(owner, opened_on: last_month)

    due = create_card_account(owner, opened_on: this_month)

    expect { op.() }.to send_email.to(account.email)

    # TODO test message body
  end

  example 'couples account with 1 card due for companion' do
    account = create_account(:couples, :eligible, :onboarded)
    owner, comp = account.people.sort_by(&:type).reverse

    # cards that aren't due:
    create_card_account(owner, opened_on: next_month)
    create_card_account(comp, opened_on: this_month, closed_on: this_month)
    create_card_account(owner, opened_on: last_month)

    due = create_card_account(comp, opened_on: this_month)

    expect { op.() }.to send_email.to(account.email)

    # TODO test message body
  end

  example 'couples account with multiple cards due for one person' do
    account = create_account(:couples, :eligible, :onboarded)
    owner, comp = account.people.sort_by(&:type).reverse

    # cards that aren't due:
    create_card_account(owner, opened_on: next_month)
    create_card_account(comp, opened_on: this_month, closed_on: this_month)
    create_card_account(owner, opened_on: last_month)

    due_0 = create_card_account(owner, opened_on: this_month)
    due_1 = create_card_account(owner, opened_on: this_month)

    expect { op.() }.to send_email.to(account.email)

    # TODO test message body
  end

  example 'couples account with cards for both owner and companion' do
    account = create_account(:couples, :eligible, :onboarded)
    owner, comp = account.people.sort_by(&:type).reverse

    # cards that aren't due:
    create_card_account(owner, opened_on: next_month)
    create_card_account(comp, opened_on: this_month, closed_on: this_month)
    create_card_account(owner, opened_on: last_month)

    due_0 = create_card_account(owner, opened_on: this_month)
    due_1 = create_card_account(owner, opened_on: this_month)
    due_2 = create_card_account(comp, opened_on: this_month)

    expect { op.() }.to send_email.to(account.email)

    # TODO test message body
  end
end

namespace :ab do
  # Create the sample data that will be used by CardMailerPreview
  task card_mailer_sample_data: :environment do
    require Rails.root.join('spec/support/sample_data_macros').to_s
    include SampleDataMacros
    a = create_account email: 'card_mailer_test@example.com'
    3.times { create_card_account(person: a.owner) }
    a = create_account email: 'card_mailer_test_couples@example.com'
    create_companion(account: a)
    3.times { create_card_account(person: a.owner) }
    3.times { create_card_account(person: a.companion) }
  end

  # this data is better for testing in production, methinks. Based on
  # send_annual_fee_reminder_spec.rb
  #
  # This is a crude and ugly way of testing in production that the right
  # annual fee reminders get sent. To test it you'll need to:
  #   - make sure that the *Month vars below have dates that make sense,
  #     given the variable names
  #   - update the recipient emails to make sure that the right people will
  #     recieve the test emails.
  #   - delete the test accounts if they already exist (otherwise this script
  #     will try to create them again, which will crash)
  #   - set ANNUAL_FEE_REMINDER_TEST_MODE to true in production, if
  #     today is not the first of the month (MAKE SURE TO UNSET IT AGAIN
  #     AFTER YOU'RE DONE!)
  #   - run this task in production
  #   - run the rake task that actually sends the emails
  #   - you should receive some emails at the specified address. Look
  #     through the code and make sure the emails make sense!
  #   - reminder: UNSET ANNUAL_FEE_REMINDER_TEST_MODE. Seriously
  task card_mailer_sample_data_2: :environment do
    ApplicationRecord.transaction do
      require Rails.root.join('spec/support/sample_data_macros').to_s
      include SampleDataMacros

      # you'll need to update these vars if you want to test again in future.
      LastMonth = Date.new(2017, 6, 30)
      NextMonth = Date.new(2017, 8, 1)
      ThisMonth = Date.new(2017, 7, 15)

      def create_couples_account(who, plus)
        email = "#{who}+#{plus}@gmail.com"
        create_account(:couples, :eligible, :onboarded, email: email)
      end

      def create_solo_account(who, plus)
        email = "#{who}+#{plus}@gmail.com"
        create_account(:eligible, :onboarded, email: email)
      end

      def create_card_account(person, attrs = {})
        super(attrs.merge(person: person))
      end

      def create_undue_cards_for_person(*people)
        people.each do |person|
          create_card_account(person, opened_on: NextMonth)
          create_card_account(person, opened_on: ThisMonth, closed_on: ThisMonth)
          create_card_account(person, opened_on: LastMonth)
        end
      end

      %w[georgejulianmillo paquet2386].each do |address|
        # no cards
        create_solo_account(address, 'no-af-0')

        # no cards with af due
        account = create_solo_account(address, 'no-af-1')
        create_undue_cards_for_person(account.owner)

        # solo, 1 card due
        account = create_solo_account(address, 'solo-1-due')
        person = account.owner
        create_undue_cards_for_person(account.owner)
        create_card_account(person, opened_on: this_month) # due

        # solo, multiple due
        account = create_solo_account(address, 'solo-multiple-due')
        person = account.owner
        create_undue_cards_for_person(account.owner)
        create_card_account(person, opened_on: this_month) # due
        create_card_account(person, opened_on: this_month) # due

        # couples, 1 due for owner
        account = create_couples_account(address, 'couples-owner-1-due')
        owner, companion = account.people.sort_by(&:type).reverse
        create_undue_cards_for_person(owner, companion)
        create_card_account(owner, opened_on: this_month) # due

        # couples, 1 due for companion
        account = create_couples_account(address, 'couples-companion-1-due')
        owner, companion = account.people.sort_by(&:type).reverse
        create_undue_cards_for_person(owner, companion)
        create_card_account(companion, opened_on: this_month) # due

        # couples, multiple cards for one person
        account = create_couples_account(address, 'couples-owner-multi-due')
        owner, companion = account.people.sort_by(&:type).reverse
        create_undue_cards_for_person(owner, companion)
        create_card_account(owner, opened_on: this_month) # due
        create_card_account(owner, opened_on: this_month) # due

        # couples, cards for both people
        account = create_couples_account(address, 'couples-both-due')
        owner, companion = account.people.sort_by(&:type).reverse
        create_undue_cards_for_person(owner, companion)
        create_card_account(owner, opened_on: this_month) # due
        create_card_account(owner, opened_on: this_month) # due
        create_card_account(companion, opened_on: this_month) # due
      end
    end
  end
end

require 'abroaders/util'

require_relative 'operation_macros'

# A replacement for FactoryGirl that exclusively creates and updates data using
# our own operations, and therefore creates data in the exact same way that a
# user would. Ideally all test data should be created in this way and we would
# do away with FactoryGirl altogether.
#
# The macros in here are long and VERY ugly but they're a start; ideally we'd
# have some kind of unified interface similar to FactoryGirl's "create" method
# that delegates to methods like the one below
#
# Some of these methods have a FactoryGirl-like interface where you can pass
# both 'traits' and 'overrides', but I want to move away from 'traits', they're
# too magical.
module SampleDataMacros
  include FactoryGirl::Syntax::Methods
  include OperationMacros

  def sample_json(file_name)
    File.read(SPEC_ROOT.join('support', 'sample_data', "#{file_name}.json"))
  end

  def parsed_sample_json(file_name, underscore_keys: true)
    hash = JSON.parse(sample_json(file_name))
    if underscore_keys
      Abroaders::Util.underscore_keys(hash, true)
    else
      hash
    end
  end

  class Generator
    include FactoryGirl::Syntax::Methods
    include OperationMacros

    def self.instance
      @instance ||= new
    end

    def initialize
      @sequences ||= {}
    end

    # Create an account. At present only the initial account sign up is
    # performed with a 'real' operation. You can pass in the traits :couples,
    # :onboarded, and :eligible, and they'll update the model directly without
    # going through an op.
    #
    # Available overrides: email, onboarding_state
    # Available traits: eligible, onboarded, couples
    def account(*traits_and_overrides)
      n = increment_sequence(:account)
      overrides = if traits_and_overrides.last.is_a?(Hash)
                    traits_and_overrides.pop
                  else
                    {}
                  end
      traits = traits_and_overrides

      attrs = {
        email: "#account-#{n}@example.com",
        password: 'abroaders123',
        password_confirmation: 'abroaders123',
        first_name: 'Erik',
      }.merge(overrides)

      ApplicationRecord.transaction do
        account = run!(Registration::Create, account: attrs)['model']
        account.create_companion!(first_name: 'Gabi') if traits.include?(:couples)
        if traits.include?(:eligible)
          account.people.update_all(eligible: true)
          account.reload
        end
        if traits.include?(:onboarded)
          account.update!(onboarding_state: 'complete') unless account.onboarded?
        elsif overrides.key?(:onboarding_state) && overrides[:onboarding_state] != account.onboarding_state
          account.update!(onboarding_state: overrides[:onboarding_state])
        end
        if overrides.key?(:monthly_spending_usd)
          account.update!(monthly_spending_usd: overrides[:monthly_spending_usd])
        end
        account
      end
    end

    # @return [Admin]
    def admin(overrides = {})
      n = increment_sequence(:admin)

      avatar = File.open(Rails.root.join('spec', 'support', 'erik.png'))

      attrs = {
        first_name: 'A.D.',
        last_name: "Min #{n}",
        email: "admin-#{n}@example.com",
        password: 'abroaders123',
        avatar: avatar,
      }.merge(overrides)

      Admin.create!(attrs)
    end

    # @return [Balance]
    def balance(overrides = {})
      raise 'pass currency, not currency_id' if overrides.key?(:currency_id)
      kurrency = if overrides.key?(:currency)
                   overrides.delete(:currency)
                 else
                   currency
                 end

      raise 'pass person, not person_id' if overrides.key?(:person_id)
      persun = if overrides.key?(:person)
                 overrides.delete(:person)
               else
                 account.owner
               end

      run!(
        Balance::Create,
        { # defaults:
          balance: {
            currency_id: kurrency.id,
            person_id: persun.id,
            value: 1,
          }.merge(overrides),
        },
        'current_account' => persun.account,
      )['model']
    end

    # @return [Currency]
    def currency(overrides = {})
      n = increment_sequence(:currency)

      run!(
        AdminArea::Currencies::Create,
        currency: {
          name: "Currency #{n}",
          award_wallet_id: "currency #{n}",
          alliance_name: %w[OneWorld StarAlliance SkyTeam Independent][n % 4],
          shown_on_survey: true,
          type: 'airline',
        }.merge(overrides),
      )['model']
    end

    # @option overrides [CardProduct] card_product_id if not provided,
    #   a new card product will be created
    def offer(overrides = {})
      attrs = { # defaults
        condition: 'on_minimum_spend',
        cost: rand(20) * 5,
        days: [30, 60, 90, 90, 90, 90, 90, 90, 120].sample,
        link: Faker::Internet.url('example.com'),
        partner: 'card_benefit',
        points_awarded: rand(20) * 5_000,
        spend: rand(10) * 500,
      }.merge(overrides)

      card_product = if overrides.key?(:card_product)
                       overrides.fetch(:card_product)
                     else
                       create(:card_product)
                     end

      run!(
        AdminArea::Offers::Create,
        offer: attrs,
        card_product_id: card_product.id,
      )['model']
    end

    # Create a sample travel plan. Tries to use existing airports from the DB if
    # it can find any; else creates two new airports (one for 'from' and one for
    # 'to') using FactoryGirl.
    #
    # note that this macro takes an airport as the values for 'from' and 'to',
    # but the underlying 'Create' operation takes the airport's "full_name"
    # string
    #
    # If you provide a return_on date but no type, type will default to 'round_trip'.
    # If you say that type == 'round_trip' but don't provide a return_on date, the
    # return_on date will default to a random date at some point shortly after
    # the depart_on date. (depart_on itself, when not provided, defaults to a
    # random date in the near future.)
    #
    # @option overrides [Account] account the account the travel plan will belong
    #   to. If you don't provide an account, FactoryGirl will be used to create
    #   one
    def travel_plan(overrides = {})
      # It's annoying how I can't use ivars with names like 'account' that
      # will conflict with a method name. Maybe my design needs rethinking.
      airports = Airport.all.to_a
      from = if overrides.key?(:from)
               overrides.delete(:from)
             elsif airports.any?
               airports.pop
             else
               create(:airport)
             end

      to = if overrides.key?(:to)
             overrides.delete(:to)
           elsif airports.any?
             airports.pop
           else
             create(:airport)
           end

      # symbols will make the operation crash:
      overrides[:type] = overrides[:type].to_s if overrides.key?(:type)

      attributes = { # defaults:
        accepts_economy: true,
        depart_on: rand(5).days.from_now,
        no_of_passengers: rand(2) + 1,
        type: 'one_way',
        from: from.full_name,
        to: to.full_name,
      }.merge(overrides)

      attributes[:type] = 'round_trip' if attributes.key?(:return_on)

      if attributes[:type] == 'round_trip' && !attributes.key?(:return_on)
        attributes[:return_on] = attributes[:depart_on] + rand(15)
      end

      params = { travel_plan: attributes }

      akkount = overrides.key?(:account) ? overrides.delete(:account) : account

      run!(TravelPlan::Create, params, 'current_account' => akkount)['model']
    end

    private

    # Not all macros have 'sequence' functionality, as I haven't needed it yet

    # @return the new, incremented sequence number
    def increment_sequence(model_name)
      @sequences[model_name] ||= -1
      @sequences[model_name] += 1
    end
  end

  def create_account(*traits_and_overrides)
    Generator.instance.account(*traits_and_overrides)
  end

  %w[admin balance currency travel_plan offer].each do |model_name|
    define_method "create_#{model_name}" do |overrides = {}|
      Generator.instance.send(model_name, overrides)
    end
  end

  # Create a card recommendation in the same way a user would.
  #
  # Actually, it's not quite the same way a user would, because not all the
  # state changes are performed by operations. But you're probably better off
  # not using the traits here anyway.
  #
  # available traits:
  # :applied
  # :approved
  # :called
  # :expired
  # :nudged
  # :denied
  # :redenied
  def create_card_recommendation(*traits_and_overrides)
    overrides = if traits_and_overrides.last.is_a?(Hash)
                  traits_and_overrides.pop
                else
                  {}
                end

    offer_id = if overrides.key?(:offer)
                 overrides[:offer].id
               elsif overrides.key?(:offer_id)
                 overrides[:offer_id]
               else
                 create_offer.id
               end

    person_id = if overrides.key?(:person)
                  overrides[:person].id
                elsif overrides.key?(:person_id)
                  overrides[:person_id]
                else
                  create_account.owner.id
                end

    admin = if overrides.key?(:current_admin)
              overrides.fetch(:current_admin)
            else
              create_admin
            end

    rec = run!(
      AdminArea::CardRecommendations::Create,
      { card: { offer_id: offer_id }, person_id: person_id },
      'current_admin' => admin,
    )['model']

    traits = traits_and_overrides

    rec.applied_on = 4.days.ago if traits.include?(:applied)

    rec.seen_at = 6.days.ago if traits.include?(:seen)
    rec.clicked_at = 5.days.ago if traits.include?(:clicked)

    if traits.include?(:approved)
      rec.applied_on = 4.days.ago
      rec.opened_on  = Date.today
    end

    if traits.include?(:called)
      rec.applied_on = 4.days.ago
      rec.denied_at  = 3.days.ago
      rec.called_at  = Time.zone.now
    end

    rec.expired_at = Time.zone.now if traits.include?(:expired)

    if traits.include?(:nudged)
      rec.applied_on = 4.days.ago
      rec.nudged_at = Time.zone.now
    end

    if traits.include?(:denied)
      rec.applied_on = 4.days.ago
      rec.denied_at  = 3.days.ago
    end

    if traits.include?(:redenied)
      rec.applied_on = 4.days.ago
      rec.denied_at  = 3.days.ago
      rec.called_at  = Time.zone.now
      rec.redenied_at = Time.zone.now
    end

    rec.save!
    rec
  end

  alias create_rec create_card_recommendation

  def create_card_account(overrides = {})
    raise 'use :card_product, not :product' if overrides.key?(:product)
    raise 'use :card_product_id, not :product_id' if overrides.key?(:product_id)

    if overrides.key?(:card_product) && overrides.key?(:card_product_id)
      raise "can't specify both :card_product and :card_product_id, use one or the other"
    end
    card_product_id = if overrides.key?(:card_product)
                        overrides[:card_product].id
                      elsif overrides.key?(:card_product_id)
                        overrides[:card_product_id]
                      else
                        create(:card_product).id
                      end

    params = {
      card: {
        opened_on: overrides.fetch(:opened_on, Date.today),
      },
      card_product_id: card_product_id,
    }

    raise "can't use :person_id, pass :person instead" if overrides.key?(:person_id)
    if overrides.key?(:person)
      person = overrides.fetch(:person)
      params[:person_id] = person.id
    else
      person = create_account.owner
    end

    if overrides.key?(:closed_on)
      params[:card][:closed] = true
      params[:card][:closed_on] = overrides.fetch(:closed_on, Date.today)
    end

    run!(CardAccount::Create, params, 'current_account' => person.account)['model']
  end

  def create_recommendation_request(person_type, account)
    unless %w[owner companion both].include?(person_type)
      raise "invalid person type '#{person_type}'"
    end

    run!(
      RecommendationRequest::Create,
      { person_type: person_type },
      'current_account' => account,
    )['model']
  end

  alias create_rec_request create_recommendation_request

  # Run the Kill operation on an offer
  #
  # @return [Offer] the now-dead Offer that you passed in
  def kill_offer(offer)
    run!(AdminArea::Offers::Kill, id: offer.id)['model']
  end

  # Run the Verify operation on an offer
  #
  # @return [Offer] the now-verified Offer that you passed in
  def verify_offer(offer)
    run!(AdminArea::Offers::Verify, id: offer.id)['model']
  end

  def decline_rec(rec, decline_reason: 'Example decline reason')
    run!(
      CardRecommendation::Decline,
      { id: rec.id, card: { decline_reason: decline_reason } },
      'current_account' => rec.account,
    )['model']
  end

  def complete_recs(account_or_person)
    person = if account_or_person.is_a?(Person)
               account_or_person
             else
               account_or_person.owner
             end

    run!(AdminArea::CardRecommendations::Complete, person_id: person.id)
  end
end

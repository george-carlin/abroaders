require 'abroaders/util'

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

  # Create an offer in the way an Admin would.
  def create_offer(overrides = {})
    attrs = { # defaults
      condition: 'on_minimum_spend',
      cost: rand(20) * 5,
      days: [30, 60, 90, 90, 90, 90, 90, 90, 120].sample,
      link: Faker::Internet.url('example.com'),
      partner: 'card_benefit',
      points_awarded: rand(20) * 5_000,
      spend: rand(10) * 500,
    }

    product_id = overrides.fetch(:product, create(:product)).id

    run!(
      AdminArea::Offers::Operation::Create,
      offer: attrs,
      card_product_id: product_id,
    )['model']
  end

  # Create a card recommendation in the same way a user would.
  #
  # Actually, it's not quite the same way a user would, because not all the
  # state changes are performed by operations. But you're probably better off
  # not using the traits here anyway.
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
                  create(:person).id
                end

    rec = run!(
      AdminArea::CardRecommendations::Operation::Create,
      card_recommendation: { offer_id: offer_id }, person_id: person_id,
    )['model']

    traits = traits_and_overrides

    # TODO extract ops for these actions
    rec.applied_on = 4.days.ago if traits.include?(:applied)

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

    rec.pulled_at = Time.zone.now if traits.include?(:pulled)

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

  def create_card_account(*traits_and_overrides)
    overrides = if traits_and_overrides.last.is_a?(Hash)
                  traits_and_overrides.pop
                else
                  {}
                end
    traits = traits_and_overrides

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
      card_account: {
        opened_on: overrides.fetch(:opened_on, Date.today),
      },
      card_product_id: card_product_id,
    }

    raise "can't use :person_id, pass :person instead" if overrides.key?(:person_id)
    if overrides.key?(:person)
      person = overrides.fetch(:person)
      params[:person_id] = person.id
    else
      person = create(:person)
    end

    if traits.include?(:closed) || overrides.key?(:closed_on)
      params[:card_account][:closed] = true
      params[:card_account][:closed_on] = overrides.fetch(:closed_on, Date.today)
    end

    run!(CardAccount::Create, params, 'account' => person.account)['model']
  end

  # Create a sample travel plan. Tries to use existing airports from the DB if
  # it can find any; else creates two new airports (one for 'from' and one for
  # 'to') using FactoryGirl.
  #
  # note that this macro takes an airport as the values for 'from' and 'to',
  # but the underlying 'Create' operation takes the airport's "full_name"
  # string
  #
  # If you provide a return_on date but no type, type will default to 'return'.
  # If you say that type == 'return' but don't provide a return_on date, the
  # return_on date will default to a random date at some point shortly after
  # the depart_on date. (depart_on itself, when not provided, defaults to a
  # random date in the near future.)
  #
  # @option overrides [Account] account the account the travel plan will belong
  #   to. If you don't provide an account, FactoryGirl will be used to create
  #   one
  def create_travel_plan(overrides = {})
    account = overrides.key?(:account) ? overrides.delete(:account) : create(:account)

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
      type: 'single',
      from: from.full_name,
      to: to.full_name,
    }.merge(overrides)

    attributes[:type] = 'return' if attributes.key?(:return_on)

    if attributes[:type] == 'return' && !attributes.key?(:return_on)
      attributes[:return_on] = attributes[:depart_on] + rand(15)
    end

    params = { travel_plan: attributes }

    run!(TravelPlan::Create, params, 'account' => account)['model']
  end

  # Run the Kill operation on an offer
  #
  # @return [Offer] the now-dead Offer that you passed in
  def kill_offer(offer)
    run!(AdminArea::Offers::Operation::Kill, id: offer.id)['model']
  end

  # Run the Verify operation on an offer
  #
  # @return [Offer] the now-verified Offer that you passed in
  def verify_offer(offer)
    run!(AdminArea::Offers::Operation::Verify, id: offer.id)['model']
  end
end

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
# This method has an interface like FactoryGirl's, in that you can pass both
# traits (an array of symbols; you don't have to pass any traits) and a hash
# of attributes.
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
  #
  # Valid traits are ':verified', which means an admin will verify the offer
  # after creating it, and ':dead', which means an admin will kill the offer
  # after creating it.
  def create_offer(*traits_and_overrides)
    overrides = if traits_and_overrides.last.is_a?(Hash)
                  traits_and_overrides.pop
                else
                  {}
                end

    if overrides.keys.include?(:last_reviewed_at)
      raise 'invalid key :last_reviewed_at, pass :verified as a trait'
    end
    if overrides.keys.include?(:killed_at)
      raise 'invalid key :killed_at, pass :dead as a trait'
    end

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

    offer = run!(
      AdminArea::Offers::Operation::Create,
      offer: attrs,
      card_product_id: product_id,
    )['model']

    traits = traits_and_overrides
    if traits.include?(:verified)
      result = AdminArea::Offers::Operation::Verify.(id: offer.id)
      raise unless result.success?
      offer = result['model']
    end
    if traits.include?(:dead)
      result = AdminArea::Offers::Operation::Kill.(id: offer.id)
      raise unless result.success?
      offer = result['model']
    end

    offer
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

    raise "don't use :offer as a key, pass :offer_id" if overrides.key?(:offer)
    raise "don't use :person as a key, pass :person_id" if overrides.key?(:person)

    offer_id  = overrides.fetch(:offer_id, create_offer.id)
    person_id = overrides.fetch(:person_id, create(:person).id)

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

  def create_card(*traits_and_overrides)
    overrides = if traits_and_overrides.last.is_a?(Hash)
                  traits_and_overrides.pop
                else
                  {}
                end
    traits = traits_and_overrides

    if overrides.key?(:product) && overrides.key?(:product_id)
      raise "can't specify both :product and :product_id, use one or the other"
    end
    product_id = if overrides.key?(:product)
                   overrides[:product].id
                 elsif overrides.key(:product_id)
                   overrides[:product_id]
                 else
                   create(:card_product).id
                 end

    raise "can't use :person_id, pass :person instead" if overrides.key?(:person_id)
    person = overrides.fetch(:person, create(:person))

    params = {
      card: {
        opened_on: overrides.fetch(:opened_on, Date.today),
      },
      product_id: product_id,
    }

    if traits.include?(:closed) || overrides.key(:closed_on)
      params[:card][:closed] = true
      params[:card][:closed_on] = overrides.fetch(:closed_on, Date.today)
    end

    run!(Card::Operation::Create, params, 'account' => person.account)['model']
  end
end

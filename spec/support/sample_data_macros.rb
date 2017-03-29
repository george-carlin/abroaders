# A replacement for FactoryGirl that exclusively creates and updates data using
# our own operations, and therefore creates data in the exact same way that a
# user would. Ideally all test data should be created in this way and we would
# do away with FactoryGirl altogether. This method is long and ugly but it's a
# start; ideally we'd have some kind of unified interface similar to
# FactoryGirl's "create" method that delegates to methods like the one below
#
# This method has an interface like FactoryGirl's, in that you can pass both
# traits (an array of symbols; you don't have to pass any traits) and a hash
# of attributes.
module SampleDataMacros
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
  # not using the traits here anyway. They're too magical
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
end

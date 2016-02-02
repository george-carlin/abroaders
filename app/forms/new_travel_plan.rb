# See the 'form objects' section of:
# http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/
class NewTravelPlan
  include Virtus.model
  include ActiveModel::Validations

  attribute :user, User
  attribute :type, Symbol
  attribute :legs, Array

  def legs=(legs)
    @legs = legs.map { |l| Leg.new(l) }
  end

  validates :user, presence: true
  validates :type, inclusion: { in: TravelPlan::TYPES }

  validate :has_correct_number_of_legs
  validate :legs_are_valid

  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def save!
    if valid?
      persist!
      true
    else
      raise ActiveRecord::RecordInvalid.new(self)
    end
  end

  private

  def has_correct_number_of_legs
    if type == :single
      if !legs || legs.length != 1
        errors.add(:base, "single travel plans must have exactly one leg")
      end
    end
  end

  def legs_are_valid
    legs.each_with_index do |leg, i|
      unless leg.valid?
        leg.errors.each do |attr, message|
          errors.add("leg_#{i}.#{attr}", message)
        end
      end
    end
  end

  def persist!
    ActiveRecord::Base.transaction do
      plan = TravelPlan.new(user: user)
      legs.each_with_index do |leg, i|
        attrs = leg.attributes
        attrs[:position] = i
        plan.legs.build(attrs)
      end
      plan.save!
    end
  end

  class Leg
    include Virtus.model
    include ActiveModel::Validations

    attribute :from,       Destination
    attribute :to,         Destination
    attribute :date_range, Range

    def earliest
      date_range.try(:first)
    end

    def latest
      date_range.try(:last)
    end

    validates :from,       presence: true
    validates :to,         presence: true
    validates :date_range, presence: true

    validate :date_range_is_a_date_range, if: -> { date_range.present? }
    validate :from_and_to_cant_be_the_same
    validate :dates_are_not_in_the_past, if: -> { date_range.present? }
    validate :dates_are_in_the_right_order, if: -> { date_range.present? }

    private

    def date_range_is_a_date_range
      if !(date_range.is_a?(Range) && earliest.is_a?(Date) && latest.is_a?(Date))
        errors.add(:date_range, "is not a valid range of dates")
      end
    end

    def dates_are_not_in_the_past
      if earliest < Date.today ||
          (date_range.exclude_end? && latest <= Date.today) ||
          (!date_range.exclude_end? && latest < Date.today)
        errors.add(:fucker, "shit")
      end
    end

    def from_and_to_cant_be_the_same
      if from && to && from == to
        errors.add(:to, "can't be the same as the origin")
      end
    end

    def dates_are_in_the_right_order
      if latest < earliest
        errors.add(:date_range, "earliest possible date can't be after latest possible date")
      end
    end

  end
end

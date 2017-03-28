class Card::Status
  include Virtus.model
  include ActiveModel::Validations

  TIMESTAMPS = %w[
    recommended_at
    declined_at
    applied_on
    denied_at
    opened_on
    nudged_at
    called_at
    redenied_at
    closed_on
    expired_at
    pulled_at
  ].freeze

  TIMESTAMPS.each do |timestamp|
    attribute timestamp, Date
  end

  validate :timestamps_make_sense

  def name
    # Note: the order of these return statements matters!
    return "pulled"      unless pulled_at.nil?
    return "expired"     unless expired_at.nil?
    return "closed"      unless closed_on.nil?
    return "open"        unless opened_on.nil?
    return "declined"    unless declined_at.nil?
    return "denied"      unless denied_at.nil?
    return "applied"     unless applied_on.nil?
    return "recommended" unless recommended_at.nil?
    raise "this should never happen!"
  end

  private

  def timestamps_make_sense
    if recommended_at.nil?
      %i[declined_at applied_on denied_at nudged_at
         called_at redenied_at expired_at].each do |timestamp|
        errors.add(timestamp, :present) if attributes[timestamp].present?
      end
      errors.add(:opened_on, :blank) if opened_on.nil?
      return
    end

    unless declined_at.nil?
      %i[
        applied_on denied_at nudged_at called_at redenied_at opened_on closed_on
        expired_at pulled_at
      ].each do |timestamp|
        errors.add(timestamp, :present) if attributes[timestamp].present?
      end
      return
    end

    unless expired_at.nil?
      %i[
        applied_on nudged_at called_at redenied_at opened_on closed_on
        denied_at pulled_at
      ].each do |timestamp|
        errors.add(timestamp, :present) if attributes[timestamp].present?
      end
      return
    end

    if applied_on.nil?
      %i[denied_at nudged_at called_at redenied_at opened_on closed_on pulled_at].each do |timestamp|
        errors.add(timestamp, :present) if attributes[timestamp].present?
      end
    else
      errors.add(:opened_on, :blank) if closed_on.present? && opened_on.nil?
      errors.add(:denied_at, :blank) if redenied_at.present? && denied_at.nil?
    end
  end
end

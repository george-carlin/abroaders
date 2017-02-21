class Card::Status
  include Virtus.model
  include ActiveModel::Validations

  TIMESTAMPS = %w[
    recommended_at
    declined_at
    applied_at
    denied_at
    opened_at
    nudged_at
    called_at
    redenied_at
    closed_at
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
    return "closed"      unless closed_at.nil?
    return "open"        unless opened_at.nil?
    return "declined"    unless declined_at.nil?
    return "denied"      unless denied_at.nil?
    return "applied"     unless applied_at.nil?
    return "recommended" unless recommended_at.nil?
    raise "this should never happen!"
  end

  private

  def timestamps_make_sense
    if recommended_at.nil?
      %i[declined_at applied_at denied_at nudged_at
         called_at redenied_at expired_at].each do |timestamp|
        errors.add(timestamp, :present) if attributes[timestamp].present?
      end
      errors.add(:opened_at, :blank) if opened_at.nil?
      return
    end

    unless declined_at.nil?
      %i[
        applied_at denied_at nudged_at called_at redenied_at opened_at closed_at
        expired_at pulled_at
      ].each do |timestamp|
        errors.add(timestamp, :present) if attributes[timestamp].present?
      end
      return
    end

    unless expired_at.nil?
      %i[
        applied_at nudged_at called_at redenied_at opened_at closed_at
        denied_at pulled_at
      ].each do |timestamp|
        errors.add(timestamp, :present) if attributes[timestamp].present?
      end
      return
    end

    if applied_at.nil?
      %i[denied_at nudged_at called_at redenied_at opened_at closed_at pulled_at].each do |timestamp|
        errors.add(timestamp, :present) if attributes[timestamp].present?
      end
    else
      errors.add(:opened_at, :blank) if closed_at.present? && opened_at.nil?
      errors.add(:denied_at, :blank) if redenied_at.present? && denied_at.nil?
    end
  end
end

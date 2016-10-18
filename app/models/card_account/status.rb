class CardAccount::Status
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
    return "pulled"      if pulled_at.present?
    return "expired"     if expired_at.present?
    return "closed"      if closed_at.present?
    return "open"        if opened_at.present?
    return "declined"    if declined_at.present?
    return "denied"      if denied_at.present?
    return "applied"     if applied_at.present?
    return "recommended" if recommended_at.present?
    raise "this should never happen!"
  end

  def show_survey?
    case name
    when "recommended"
      true
    when "applied"
      true
    when "denied"
      !(nudged_at.present? || redenied_at.present?) # TODO also disallow reconsideration after 30
    else
      false
    end
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

    if declined_at.present?
      %i[
        applied_at denied_at nudged_at called_at redenied_at opened_at closed_at
        expired_at pulled_at
      ].each do |timestamp|
        errors.add(timestamp, :present) if attributes[timestamp].present?
      end
      return
    end

    if expired_at.present?
      %i[
        applied_at nudged_at called_at redenied_at opened_at closed_at
        denied_at pulled_at
      ].each do |timestamp|
        errors.add(timestamp, :present) if attributes[timestamp].present?
      end
      return
    end

    if applied_at.present?
      errors.add(:opened_at, :blank) if closed_at.present? && opened_at.nil?
      errors.add(:denied_at, :blank) if redenied_at.present? && denied_at.nil?
    else
      %i[denied_at nudged_at called_at redenied_at opened_at closed_at pulled_at].each do |timestamp|
        errors.add(timestamp, :present) if attributes[timestamp].present?
      end
    end
  end
end

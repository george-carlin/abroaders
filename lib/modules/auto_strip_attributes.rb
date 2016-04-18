# Forked from github.com/holli/auto_strip_attributes, massively simplified,
# and changed to use before_save instead of before_validation
module AutoStripAttributes
  def auto_strip_attributes(*attributes)
    opts     = attributes.extract_options!
    callback = opts.fetch(:callback, "before_save").to_s

    # whitelist callback:
    raise ArgumentError unless %w[before_validation before_save].include?(callback)

    attributes.each do |attribute|
      send(callback) do |record|
        value = record[attribute]&.strip!
        value = nil if value.blank?
        record[attribute] = value
      end
    end
  end
end

ActiveRecord::Base.send(:extend, AutoStripAttributes)

# Forked from github.com/holli/auto_strip_attributes, massively simplified,
# and changed to use before_save instead of before_validation
module AutoStripAttributes
  def auto_strip_attributes(*attributes)
    attributes.each do |attribute|
      before_save do |record|
        value = record[attribute]
        value.try(:strip!)
        value = nil if value.blank?
        record[attribute] = value
      end
    end
  end
end

ActiveRecord::Base.send(:extend, AutoStripAttributes)
